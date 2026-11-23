#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/plan-on-branch.sh" "$here/plan.md" github
# The plan is also on main, so that its presence there shows the refusal deleted nothing.
git checkout -q main
git checkout -q feature/tracking -- docs/work/tracking/plan.md
git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the plan"
