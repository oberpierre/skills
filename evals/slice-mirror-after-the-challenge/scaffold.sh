#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
cp -RL "$(dirname "$0")/bin" .eval-bin
git remote add origin git@github.com:eval/shopnotes.git
mkdir -p docs/work/prefix .agents && cp "$(dirname "$0")/plan.md" docs/work/prefix/plan.md
printf 'tracker: github\n' > .agents/config.yml
printf '.eval-bin/\n.gh-issues/\ngh-calls.log\n.gh-next\n' > .gitignore
: > gh-calls.log
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan the email prefix"
