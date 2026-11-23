#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/shipping-notes docs/work/tracking docs/work/receipts docs/work/returns
cp "$here/plan.md" docs/work/shipping-notes/plan.md
cp "$here/second.md" docs/work/tracking/plan.md
cp "$here/third.md" docs/work/receipts/plan.md
cp "$here/fourth.md" docs/work/returns/plan.md
