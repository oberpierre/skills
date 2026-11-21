#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/plan-on-branch.sh" "$here/plan.md"
"$here/../fixtures/log-merges.sh"
# Every ref pushed to the bare origin is logged, so the case can show that nothing was.
touch .eval-push.log
printf '.eval-push.log\n' >> .git/info/exclude
cat > .eval-origin.git/hooks/update <<HOOK
#!/bin/sh
echo "\$1" >> "$(pwd)/.eval-push.log"
HOOK
chmod +x .eval-origin.git/hooks/update
