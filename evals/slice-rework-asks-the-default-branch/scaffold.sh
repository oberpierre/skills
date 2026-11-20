#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
git="git -c user.name=eval -c user.email=eval@example.invalid"
$git branch -M main
$git checkout -q -b feature/sms
mkdir -p docs/work/sms
sed -e 's/| done | |/| todo | |/' "$(dirname "$0")/plan.md" > docs/work/sms/plan.md
git add -A && $git commit -q -m "Plan SMS notifications"
cp "$(dirname "$0")/plan.md" docs/work/sms/plan.md
echo "# SMS notifier" > notify/sms.md
git add -A && $git commit -q -m "Text the customer when an order ships"
