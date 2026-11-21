#!/usr/bin/env bash
# Builds the notifier fixture with its gate and a bare origin, on the branch feature/tracking,
# with the given plan committed as docs/work/tracking/plan.md and the gh stub on the PATH.
# With a second argument `github`, origin's URL names github.com and pushes still land in the bare
# repository, and every push is logged to .eval-push.log: the ref, then each file the pushed commit holds.
# Usage: plan-on-branch.sh <plan.md> [github]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plan="$1"
"$here/scaffold.sh" notifier
cp -R "$here/gated/." .
sed -i 's/^tracker: .*/tracker: github/' .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/with-origin.sh"
mkdir -p .eval-bin docs/work/tracking
cp -L "$here/gh-stub/gh" .eval-bin/gh
printf '.eval-bin/\ngh-calls.log\n.eval-push.log\n' >> .git/info/exclude
git checkout -q -b feature/tracking
cp "$plan" docs/work/tracking/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the plan"
if [[ "${2:-}" == github ]]; then
  bare="$(pwd)/.eval-origin.git"
  git remote set-url origin https://github.com/eval/shopnotes.git
  git config "url.$bare.pushInsteadOf" https://github.com/eval/shopnotes.git
  cat > "$bare/hooks/update" <<HOOK
#!/bin/sh
git ls-tree -r --name-only "\$3" | sed "s|^|\$1 |" >> "$(pwd)/.eval-push.log"
printf '%s subject: %s\n' "\$1" "\$(git log -1 --format=%s "\$3")" >> "$(pwd)/.eval-push.log"
HOOK
  chmod +x "$bare/hooks/update"
fi
