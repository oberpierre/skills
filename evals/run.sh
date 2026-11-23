#!/usr/bin/env bash
# Runs one eval case cheaply, with the grants its case.yaml names on its first
# line (`# allow-tools: <tool> ...`), and the model it was written for on its
# second (`# model: <alias>`). A case run without its grants scores garbage,
# such as a "writes nothing" grader passing because Write never existed.
#
# Evals spend the same usage limit as feature work, so the defaults are the
# cheapest run that tells anything: one run, no baseline arm, traces kept so a
# failure is read rather than rerun, and a ceiling per call. The script refuses
# to start once the evals of the last five hours have spent EVAL_BUDGET_USD.
#
# Usage: evals/run.sh <case> [--runs 3] [--baseline] [more claude plugin eval options]
#        evals/run.sh --changed <base>   one run of every case of each skill changed since <base>
#   --runs 3     only for a slice's own case: its red run and its last green run
#   --baseline   adds the no-plugin arm, only for a new case's red run
# Env:   EVAL_BUDGET_USD (default 3) per five hours, EVAL_MAX_USD (default 1.5) per call
set -euo pipefail
set -f

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_budget() {
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
    return 1
  fi
}

# The merge-base keeps a commit made on <base> after branching from running
# cases that only it changed. A case belongs to a skill by the hyphen after its
# name, so grill never takes grilling-*.
if [[ "${1:-}" == "--changed" ]]; then
  base="${2:?usage: evals/run.sh --changed <base>}"
  shift 2
  # Every case runs once, so a caller's run count or baseline arm would multiply the cost.
  for arg in "$@"; do
    [[ "$arg" == --runs || "$arg" == --baseline ]] \
      && { echo "run.sh: --changed runs each case once and takes neither --runs nor --baseline" >&2; exit 1; }
  done
  git -C "$root" rev-parse --verify --quiet "$base^{commit}" >/dev/null \
    || { echo "run.sh: --changed base '$base' is not a commit" >&2; exit 1; }
  mapfile -t skills < <(git -C "$root" diff --name-only "$base"...HEAD -- skills | awk -F/ 'NF > 2 {print $2}' | sort -u)
  status=0
  for skill in "${skills[@]}"; do
    set +f
    cases=("$root"/evals/"$skill"-*/)
    set -f
    found=0
    for dir in "${cases[@]}"; do
      [[ -f "$dir/case.yaml" ]] || continue
      found=1
      check_budget || { echo "run.sh: stopping at the budget" >&2; exit 2; }
      # Each case is its own process, so its model routing never reaches the next.
      "${BASH_SOURCE[0]}" "$(basename "$dir")" --runs 1 "$@" || rc=$?
      status=$(( status || ${rc:-0} )); rc=0
    done
    (( found )) || echo "run.sh: skills/$skill changed and has no eval case" >&2
  done
  exit "$status"
fi

name="${1:?usage: evals/run.sh <case> [--runs 3] [--baseline] [options]}"
shift
case_yaml="$root/evals/$name/case.yaml"
[[ -f "$case_yaml" ]] || { echo "run.sh: no case at evals/$name" >&2; exit 1; }

line="$(head -n 1 "$case_yaml")"
[[ "$line" == "# allow-tools:"* ]] \
  || { echo "run.sh: evals/$name/case.yaml does not start with '# allow-tools:'" >&2; exit 1; }
read -r -a grants <<< "${line#\# allow-tools:}"
line="$(sed -n 2p "$case_yaml")"
[[ "$line" == "# model:"* ]] \
  || { echo "run.sh: evals/$name/case.yaml does not have '# model:' on its second line" >&2; exit 1; }
model="${line#\# model:}"; model="${model// /}"

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

check_budget || exit 2

# A case cannot set PATH, but the eval inherits it from this shell. The sandbox
# sees only the workspace, so a case with a bin/ folder, such as a stub gh, has
# its scaffold copy it to .eval-bin/ there, and that relative entry goes first.
if [[ -d "$root/evals/$name/bin" ]]; then
  export PATH=".eval-bin:$PATH"
fi

# challenge names the opus alias in its frontmatter, so a sonnet case pins that
# alias to sonnet, and any other case must not inherit a value from the caller.
# The main session takes the same id, so one case never runs on two models.
if [[ "$model" == "sonnet" ]]; then
  model=claude-sonnet-5-5
  export ANTHROPIC_DEFAULT_OPUS_MODEL="$model"
else
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
fi

cd "$root"
exec claude plugin eval . --case "$name" --allow-tools "${grants[@]}" --model "$model" \
  --runs "$runs" --ablation "$ablation" --max-cost-usd "${EVAL_MAX_USD:-1.5}" --keep-temp \
  --scaffold --trust-plugin --no-publish --threshold 0.67 "${extra[@]}"
