#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
sed -i 's/^commit_style: .*/commit_style: arlo/' .agents/config.yml
# The gate logs, for each commit it precedes, whether that commit sets S1 to done.
python3 - "$here/gate-log.py" <<'PY'
import sys
p = "scripts/gate.py"
src = open(p).read()
marker = 'print(f"gate:'
src = src.replace(marker, open(sys.argv[1]).read() + "\n" + marker, 1)
open(p, "w").write(src)
PY
echo ".eval-commits.log" >> .git/info/exclude
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p docs/work/tracking && cp "$here/plan.md" docs/work/tracking/plan.md
