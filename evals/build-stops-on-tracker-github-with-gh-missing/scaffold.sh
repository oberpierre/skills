#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
sed -i 's/^tracker: .*/tracker: github/' .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p .eval-bin docs/work/tracking
cp -L "$here/../fixtures/gh-missing/gh" .eval-bin/gh
printf '.eval-bin/\ngh-calls.log\n' >> .git/info/exclude
cp "$here/plan.md" docs/work/tracking/plan.md
