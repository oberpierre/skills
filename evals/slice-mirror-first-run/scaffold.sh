#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
cp -RL "$(dirname "$0")/bin" .eval-bin
mkdir -p docs/work/sms .agents && cp "$(dirname "$0")/plan.md" docs/work/sms/plan.md
printf 'tracker: github\n' > .agents/config.yml
printf '.eval-bin/\ngh-calls.log\n.gh-next\n' > .gitignore
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan SMS notifications"
