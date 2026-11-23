#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../build-folds-a-review-comment/scaffold.sh"
sed -i 's/^\(| S1 .*\)| done | |/\1| rework | Rebuild it from its test |/' docs/work/shipping-notes/plan.md
M="Mark S1 for rework"
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "$M"
