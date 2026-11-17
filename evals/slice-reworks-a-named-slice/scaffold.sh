#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
git="git -c user.name=eval -c user.email=eval@example.invalid"
$git branch -M main
git remote add origin .
git update-ref refs/remotes/origin/main main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
$git checkout -q -b feature/sms
mkdir -p docs/work/sms && cp "$(dirname "$0")/plan.md" docs/work/sms/plan.md
git add -A && $git commit -q -m "Plan SMS notifications"
