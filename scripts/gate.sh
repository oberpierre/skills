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

if ! output="$("$claude_bin" plugin validate "$root" --strict 2>&1)"; then
  echo "$output" >&2
  echo "gate: claude plugin validate failed" >&2
  failed=1
fi

if (( failed )); then
  exit 1
fi
echo "gate: green"
