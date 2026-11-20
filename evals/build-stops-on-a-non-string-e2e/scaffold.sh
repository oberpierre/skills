#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
printf 'gate: python3 scripts/gate.py\ncommit_style: arlo-features\ne2e: [python3, scripts/e2e.py]\n' > .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/tracking && cp "$here/../build-stops-on-a-bad-config/plan.md" docs/work/tracking/plan.md
