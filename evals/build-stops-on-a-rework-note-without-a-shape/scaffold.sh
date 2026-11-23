#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../build-carries-out-a-rework/base.sh"
sed -i 's/^\(| S1 .*\)| rework | Squash S2 into S1 as one slice |/\1| rework | Make it better |/' docs/work/shipping-notes/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Reword the note"
