#!/usr/bin/env bash
# Checks evals/run.sh --changed through a stub `claude` that records each call.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"

# A pre-commit hook inherits GIT_INDEX_FILE and friends from the outer commit,
# which would send this throwaway repo's writes into the real index.
unset $(git rev-parse --local-env-vars)

git init -q -b main .
git config user.email t@t
git config user.name t
mkdir -p evals bin skills/nocase
cp "$root/evals/run.sh" evals/run.sh
cat > bin/claude <<'STUB'
#!/usr/bin/env bash
case_name=""; runs=""
while (( $# )); do
  case "$1" in
    --case) case_name="$2"; shift ;;
    --runs) runs="$2"; shift ;;
  esac
  shift
done
echo "$case_name runs=$runs opus=${ANTHROPIC_DEFAULT_OPUS_MODEL-UNSET}" >> "$STUB_OUT"
[[ -z "${STUB_EXIT:-}" ]] || exit "$STUB_EXIT"
if [[ -n "${STUB_COST:-}" ]]; then
  mkdir -p "$STUB_RESULTS/now"
  echo "{\"costUsd\": $STUB_COST}" > "$STUB_RESULTS/now/aggregate-result.json"
fi
STUB
chmod +x bin/claude

mkcase() {
  mkdir -p "evals/$1"
  printf '# allow-tools: Read\n# model: %s\nschema_version: "1.0"\n' "$2" > "evals/$1/case.yaml"
}
mkcase a-one sonnet
mkcase a-two opus
mkcase b-one opus
mkcase c-one sonnet
mkcase grill-one opus
mkcase grilling-one opus
for s in a b c grill grilling other nocase; do mkdir -p "skills/$s"; echo 0 > "skills/$s/SKILL.md"; done
git add -A && git commit -q -m base
git branch -q start

git checkout -q -b work
echo 1 > skills/a/SKILL.md
echo 1 > skills/grill/SKILL.md
echo 1 > skills/nocase/SKILL.md
echo 1 > skills/README.md
git commit -qam change

# A commit made on the base after branching must not run its skill.
git checkout -q start
echo 1 > skills/b/SKILL.md
git commit -qam "base moves"
git checkout -q work

out="$work/calls"
export STUB_OUT="$out" PATH="$work/bin:$PATH" EVAL_BUDGET_USD=3
unset ANTHROPIC_DEFAULT_OPUS_MODEL STUB_COST
fail=0
check() {
  if [[ "$2" != "$3" ]]; then
    printf 'run-changed: %s: expected\n%s\ngot\n%s\n' "$1" "$3" "$2" >&2
    fail=1
  fi
}

evals/run.sh --changed start >/dev/null 2>"$work/err" || echo "exited $?" >> "$out"
check "a changed skill with no case is reported, a file under skills/ is not a skill" "$(grep 'has no eval case' "$work/err")" "run.sh: skills/nocase changed and has no eval case"
check "changed skills' cases only, one run each, routing per case" "$(sort "$out")" \
"a-one runs=1 opus=claude-sonnet-5-5
a-two runs=1 opus=UNSET
grill-one runs=1 opus=UNSET"

rm -f "$out"
mkdir -p evals/results
rc=0
STUB_COST=4 STUB_RESULTS="$work/evals/results" evals/run.sh --changed start >/dev/null 2>"$work/err" || rc=$?
check "a spent budget stops before the next case" "$(cat "$out")" "a-one runs=1 opus=claude-sonnet-5-5"
check "the loop itself stops with status 2" "$rc" "2"
check "the loop says it stopped, once" "$(grep -c 'stopping at the budget' "$work/err")" "1"

rm -f "$out"
rm -rf evals/results
rc=0
STUB_EXIT=2 evals/run.sh --changed start >/dev/null 2>&1 || rc=$?
check "a case exiting 2 does not skip the remaining cases" "$(sort "$out")" \
"a-one runs=1 opus=claude-sonnet-5-5
a-two runs=1 opus=UNSET
grill-one runs=1 opus=UNSET"
check "a case exiting 2 is a failure, not the budget stop" "$rc" "1"

rm -f "$out"
rc=0
evals/run.sh --changed no-such-branch >/dev/null 2>&1 || rc=$?
check "a bad base is refused" "$rc" "1"
check "a bad base starts no case" "$(cat "$out" 2>/dev/null || true)" ""

rm -f "$out"
rc=0
evals/run.sh --changed start --runs 3 >/dev/null 2>&1 || rc=$?
check "--runs is refused with --changed" "$rc" "1"
check "a refused run starts no case" "$(cat "$out" 2>/dev/null || true)" ""
rc=0
evals/run.sh --changed start --baseline >/dev/null 2>&1 || rc=$?
check "--baseline is refused with --changed" "$rc" "1"

exit "$fail"
