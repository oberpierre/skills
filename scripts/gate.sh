#!/usr/bin/env bash
# The repository's gate: run before every commit, and by the pre-commit hook.
# Usage: scripts/gate.sh            run every check
#        scripts/gate.sh --install  make the pre-commit hook run this script
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${1:-}" == "--install" ]]; then
  hook="$(git -C "$root" rev-parse --git-path hooks)/pre-commit"
  printf '#!/bin/sh\nexec "$(git rev-parse --show-toplevel)/scripts/gate.sh"\n' > "$hook"
  chmod +x "$hook"
  echo "Installed $hook"
  exit 0
fi

# A devcontainer often has the CLI only inside the editor extension, whose
# folder name carries a version that changes with every update.
find_claude() {
  if command -v claude >/dev/null 2>&1; then
    command -v claude
    return
  fi
  shopt -s nullglob
  local found=(
    "$HOME"/.vscode-server/extensions/anthropic.claude-code-*/resources/native-binary/claude
    "$HOME"/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude
  )
  if (( ${#found[@]} )); then
    printf '%s\n' "${found[@]}" | sort -V | tail -n 1
  fi
}

claude_bin="$(find_claude)"
if [[ -z "$claude_bin" ]]; then
  echo "gate: no claude CLI found on PATH or in an editor extension" >&2
  exit 1
fi

failed=0
fail() {
  echo "gate: $1" >&2
  failed=1
}

if ! output="$("$claude_bin" plugin validate "$root" --strict 2>&1)"; then
  echo "$output" >&2
  fail "claude plugin validate failed"
fi

frontmatter_value() {
  awk -v key="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key ":") == 1 { sub("^" key ":[ ]*", ""); print; exit }
  ' "$1"
}

# The README's skills table is the documented invocation, so a skill whose
# frontmatter disagrees with it is either misdocumented or misconfigured.
readme_invoker() {
  sed -n "s/^| \`$1\` | \([^|]*\) |.*/\1/p" "$root/README.md" | sed 's/[ ]*$//'
}

max_lines=100
shopt -s nullglob
for skill_md in "$root"/skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$skill_md")")"
  name="$(frontmatter_value "$skill_md" name)"
  if [[ "$name" != "$dir" ]]; then
    fail "skills/$dir/SKILL.md: name '$name' does not match its folder"
  fi

  if ! grep -q "\"./skills/$dir\"" "$root/.claude-plugin/plugin.json"; then
    fail "skills/$dir is not listed in .claude-plugin/plugin.json"
  fi

  user_only="$(frontmatter_value "$skill_md" disable-model-invocation)"
  case "$(readme_invoker "$dir")" in
    "you") [[ "$user_only" == "true" ]] \
      || fail "skills/$dir: README says user-invoked, frontmatter lacks disable-model-invocation: true" ;;
    "agent or you") [[ "$user_only" != "true" ]] \
      || fail "skills/$dir: README says model-invoked, frontmatter sets disable-model-invocation: true" ;;
    *) fail "skills/$dir is missing from the README's skills table" ;;
  esac

  lines="$(wc -l < "$skill_md")"
  if (( lines > max_lines )); then
    echo "gate: warning: skills/$dir/SKILL.md has $lines lines, over the guideline of $max_lines" >&2
  fi
done

# A case run without the tools it relies on scores garbage, so each case names
# its grants on its first line, which evals/run.sh passes to the eval. Every
# gated tool the case allows must be granted there, or the agent never has it.
for case_yaml in "$root"/evals/*/case.yaml; do
  name="$(basename "$(dirname "$case_yaml")")"
  first="$(head -n 1 "$case_yaml")"
  if [[ "$first" != "# allow-tools:"* ]]; then
    fail "evals/$name/case.yaml does not start with '# allow-tools:'"
    continue
  fi
  # With nothing granted, evals/run.sh's --allow-tools would swallow the next option.
  if [[ "${first#\# allow-tools:}" =~ ^[[:space:]]*$ ]]; then
    fail "evals/$name/case.yaml grants no tool on its '# allow-tools:' line"
  fi
  if [[ "$(sed -n 2p "$case_yaml")" != "# model: "[a-z]* ]]; then
    fail "evals/$name/case.yaml does not have '# model: <alias>' on its second line"
  fi
  # The grant check below reads only a one-line list, so a block list would pass it unchecked.
  if grep -Eq '^ *allowed_tools:' "$case_yaml" && ! grep -Eq '^ *allowed_tools: *\[.*\] *$' "$case_yaml"; then
    fail "evals/$name/case.yaml writes allowed_tools as anything but a one-line [ ... ] list"
  fi
  allowed="$(sed -n 's/^ *allowed_tools: *\[\(.*\)\]/\1/p' "$case_yaml" | tr -d ' ')"
  for tool in Write Edit Bash; do
    if [[ ",$allowed," == *",$tool,"* && " ${first#\# allow-tools:} " != *" $tool"[\ \(]* ]]; then
      fail "evals/$name/case.yaml allows $tool but its '# allow-tools:' line does not grant it"
    fi
  done
done

if ! python3 -I "$root/evals/refresh-history.py" --check; then
  fail "an eval history is stale or broken"
fi

if ! "$root/evals/tests/run-routing.sh"; then
  fail "run.sh routed the opus alias wrongly for a sonnet or opus case"
fi

if ! "$root/evals/tests/run-changed.sh"; then
  fail "run.sh --changed runs only the changed skills' cases"
fi

if (( failed )); then
  exit 1
fi
echo "gate: green"
