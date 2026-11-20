#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
"$here/../fixtures/log-commits.sh"
mkdir -p docs/work/shipping-notes && cp "$here/plan.md" docs/work/shipping-notes/plan.md
