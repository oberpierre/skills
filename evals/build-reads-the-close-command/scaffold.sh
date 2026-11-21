#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/plan-on-branch.sh" "$here/plan.md" github
# A second plan with open slices: a close that picks the wrong plan, or reads the plan's name as the command, shows here.
mkdir -p docs/work/shipping-notes
sed -e 's/tracking/shipping-notes/g' -e 's/| done |/| todo |/' "$here/plan.md" > docs/work/shipping-notes/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the other plan"
