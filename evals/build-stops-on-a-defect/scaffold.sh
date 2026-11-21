#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/shipping-notes && cp "$here/plan.md" docs/work/shipping-notes/plan.md
git checkout -q -b feature/shipping-notes
cp "$here/attempt-email.py" notify/email.py
cp "$here/attempt-test.py" tests/test_email.py
