#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../build-folds-a-review-comment/scaffold.sh"
sed -i 's/^\(| S1 .*\)| done |/\1| todo |/' docs/work/shipping-notes/plan.md
M="Reopen S1"
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "$M"
