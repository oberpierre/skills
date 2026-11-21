#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
# The gate logs, for each commit it precedes, the slice rows that commit sets to done.
python3 - "$here/gate-log.py" <<'PY'
import sys
p = "scripts/gate.py"
src = open(p).read()
marker = 'print(f"gate:'
src = src.replace(marker, open(sys.argv[1]).read() + "\n" + marker, 1)
open(p, "w").write(src)
PY
echo ".eval-commits.log" >> .git/info/exclude
# The plan is committed, so that a commit adding it does not log the rows it already holds as done.
plan=docs/work/shipping-notes/plan.md
mkdir -p docs/work/shipping-notes
# On main S1 is built and S2 is still todo, as the plan stood before S2 was built and reworked.
sed 's/^\(| S2 .*\)| rework | .* |$/\1| todo | |/' "$here/plan.md" > $plan
python3 "$here/prebuilt.py" . s1
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"

# S2 was built on the plan's branch and not merged, and then marked for rework.
git checkout -q -b feature/shipping-notes
python3 "$here/prebuilt.py" . s2
sed -i 's/^\(| S2 .*\)| todo | |/\1| done | |/' $plan
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "^ F A shipped order's message names the carrier"
cp "$here/plan.md" $plan
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Mark S2 for rework"
