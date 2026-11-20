#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
mkdir -p docs/work/sms && cp "$here/plan.md" docs/work/sms/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan SMS notifications"
bash "$here/slice.sh"
