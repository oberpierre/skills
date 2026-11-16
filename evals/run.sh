#!/usr/bin/env bash
# Runs one eval case cheaply, with the grants its case.yaml names on its first
# line (`# allow-tools: <tool> ...`). A case run without its grants scores
# garbage, such as a "writes nothing" grader passing because Write never existed.
#
# Evals spend the same usage limit as feature work, so the defaults are the
# cheapest run that tells anything: one run, no baseline arm, traces kept so a
# failure is read rather than rerun, and a ceiling per call. The script refuses
# to start once the evals of the last five hours have spent EVAL_BUDGET_USD.
#
# Usage: evals/run.sh <case> [--runs 3] [--baseline] [more claude plugin eval options]
#   --runs 3     only for a slice's own case: its red run and its last green run
#   --baseline   adds the no-plugin arm, only for a new case's red run
# Env:   EVAL_BUDGET_USD (default 3) per five hours, EVAL_MAX_USD (default 1.5) per call
set -euo pipefail
set -f

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:?usage: evals/run.sh <case> [--runs 3] [--baseline] [options]}"
shift
case_yaml="$root/evals/$name/case.yaml"
[[ -f "$case_yaml" ]] || { echo "run.sh: no case at evals/$name" >&2; exit 1; }

line="$(head -n 1 "$case_yaml")"
[[ "$line" == "# allow-tools:"* ]] \
  || { echo "run.sh: evals/$name/case.yaml does not start with '# allow-tools:'" >&2; exit 1; }
read -r -a grants <<< "${line#\# allow-tools:}"

runs=1
ablation=none
extra=()
while (( $# )); do
  case "$1" in
    --runs) runs="$2"; shift 2 ;;
    --baseline) ablation=with-without; shift ;;
    *) extra+=("$1"); shift ;;
  esac
done

budget="${EVAL_BUDGET_USD:-3}"
spent="$(python3 -I - "$root/evals/results" <<'EOF'
import json, sys, time
from pathlib import Path
total = 0.0
for f in Path(sys.argv[1]).glob("*/aggregate-result.json"):
    if time.time() - f.stat().st_mtime > 5 * 3600:
        continue
    r = json.loads(f.read_text())
    total += r.get("costUsd") or sum(c.get("costUsd", 0) for c in r.get("cases", []))
print(f"{total:.2f}")
EOF
)"
if python3 -c "import sys; sys.exit(0 if float('$spent') < float('$budget') else 1)"; then
  echo "run.sh: evals spent \$$spent of \$$budget in the last five hours" >&2
else
  echo "run.sh: evals spent \$$spent in the last five hours, at the \$$budget budget. Stop and ask the user before running more, or set EVAL_BUDGET_USD if they raised it." >&2
  exit 2
fi

cd "$root"
exec claude plugin eval . --case "$name" --allow-tools "${grants[@]}" \
  --runs "$runs" --ablation "$ablation" --max-cost-usd "${EVAL_MAX_USD:-1.5}" --keep-temp \
  --scaffold --trust-plugin --no-publish --threshold 0.67 "${extra[@]}"
