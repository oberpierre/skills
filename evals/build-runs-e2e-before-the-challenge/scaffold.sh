#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
cp "$here/e2e.py" scripts/e2e.py
echo "e2e: python3 scripts/e2e.py" >> .agents/config.yml
echo ".eval-e2e.log" >> .git/info/exclude
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/shipping-notes && cp "$here/plan.md" docs/work/shipping-notes/plan.md
