#!/usr/bin/env bash
# Checks evals/run.sh's model routing through a stub `claude` that records its environment.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/evals" "$work/bin"
cp "$root/evals/run.sh" "$work/evals/run.sh"
cat > "$work/bin/claude" <<'STUB'
#!/usr/bin/env bash
while (( $# )); do
  [[ "$1" == --model ]] && model="$2"
  shift
done
echo "${ANTHROPIC_DEFAULT_OPUS_MODEL-UNSET} ${model-NONE}" > "$STUB_OUT"
STUB
chmod +x "$work/bin/claude"

for m in sonnet opus; do
  mkdir -p "$work/evals/c-$m"
  printf '# allow-tools: Read\n# model: %s\nschema_version: "1.0"\n' "$m" > "$work/evals/c-$m/case.yaml"
done

routed() {
  rm -f "$work/out"
  STUB_OUT="$work/out" PATH="$work/bin:$PATH" EVAL_BUDGET_USD=3 "$work/evals/run.sh" "$1" >/dev/null 2>&1 \
    || { echo "run.sh exited early for $1"; return 0; }
  cat "$work/out"
}

fail=0
check() {
  if [[ "$2" != "$3" ]]; then
    echo "run-routing: $1: expected '$3', got '$2'" >&2
    fail=1
  fi
}

unset ANTHROPIC_DEFAULT_OPUS_MODEL
check "sonnet case" "$(routed c-sonnet)" "claude-sonnet-5-5 claude-sonnet-5-5"
check "opus case" "$(routed c-opus)" "UNSET opus"
export ANTHROPIC_DEFAULT_OPUS_MODEL=claude-haiku-5-5
check "opus case with the caller's variable set" "$(routed c-opus)" "UNSET opus"
check "sonnet case with the caller's variable set" "$(routed c-sonnet)" "claude-sonnet-5-5 claude-sonnet-5-5"

exit "$fail"
