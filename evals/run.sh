#!/usr/bin/env bash
# Runs one eval case with the grants its case.yaml names on its first line,
# `# allow-tools: <tool> ...`. A case run without its grants produces garbage,
# such as a "writes nothing" grader passing because Write was never available.
# Usage: evals/run.sh <case> [more claude plugin eval options, e.g. --ablation none]
set -euo pipefail
set -f

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:?usage: evals/run.sh <case> [options]}"
shift
case_yaml="$root/evals/$name/case.yaml"
[[ -f "$case_yaml" ]] || { echo "run.sh: no case at evals/$name" >&2; exit 1; }

line="$(head -n 1 "$case_yaml")"
[[ "$line" == "# allow-tools:"* ]] \
  || { echo "run.sh: evals/$name/case.yaml does not start with '# allow-tools:'" >&2; exit 1; }
read -r -a grants <<< "${line#\# allow-tools:}"

cd "$root"
exec claude plugin eval . --case "$name" --allow-tools "${grants[@]}" \
  --scaffold --trust-plugin --no-publish --threshold 0.67 "$@"
