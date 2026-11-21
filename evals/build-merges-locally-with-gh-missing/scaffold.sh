#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/plan-on-branch.sh" "$here/plan.md" github
sed -i 's/^tracker: .*/tracker: markdown/' .agents/config.yml
git add .agents/config.yml && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Use the markdown tracker"
cp -L "$here/../fixtures/gh-missing/gh" .eval-bin/gh
touch .eval-push.log
"$here/../fixtures/log-merges.sh"
