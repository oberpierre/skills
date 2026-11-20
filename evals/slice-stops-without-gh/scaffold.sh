#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
mkdir -p docs/work/sms .agents && cp "$(dirname "$0")/plan.md" docs/work/sms/plan.md
printf 'tracker: github\n' > .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan SMS notifications"
