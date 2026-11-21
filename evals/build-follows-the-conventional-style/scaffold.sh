#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
sed -i 's/^commit_style: .*/commit_style: conventional/' .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
"$here/../fixtures/log-commits.sh"
mkdir -p docs/work/tracking && cp "$here/plan.md" docs/work/tracking/plan.md
