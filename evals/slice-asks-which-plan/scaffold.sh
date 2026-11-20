#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
mkdir -p docs/work/sms docs/work/digest
cp "$(dirname "$0")/sms.md" docs/work/sms/plan.md
cp "$(dirname "$0")/digest.md" docs/work/digest/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan SMS notifications and daily digests"
