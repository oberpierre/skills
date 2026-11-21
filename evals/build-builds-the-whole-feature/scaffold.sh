#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
python3 "$here/prebuilt.py" .
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
mkdir -p docs/work/shipping-notes && cp "$here/plan.md" docs/work/shipping-notes/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
