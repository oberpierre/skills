#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/order-numbers && cp "$here/plan.md" docs/work/order-numbers/plan.md
git checkout -q -b feature/order-numbers
