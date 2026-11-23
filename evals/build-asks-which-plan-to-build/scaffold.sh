#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/shipping-notes docs/work/tracking
cp "$here/plan.md" docs/work/shipping-notes/plan.md
# A second plan with the same slices: building from it, or touching it, shows in its own table.
sed -e 's/shipping-notes/tracking/g' "$here/plan.md" > docs/work/tracking/plan.md
