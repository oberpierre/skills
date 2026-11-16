#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
mkdir -p docs/work/prefix && cp "$(dirname "$0")/plan.md" docs/work/prefix/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan the email prefix"
