#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
mkdir -p docs
cat > docs/commit-style.md <<'STYLE'
extends: arlo-features

# This repository's commit style
STYLE
printf 'gate: ""\ncommit_style: docs/commit-style.md\ntracker: jira\ne2e: [python3, scripts/e2e.py]\n' > .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/tracking && cp "$here/plan.md" docs/work/tracking/plan.md
