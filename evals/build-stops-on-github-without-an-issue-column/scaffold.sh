#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
sed -i 's/^tracker: .*/tracker: github/' .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
mkdir -p .eval-bin
cp -L "$here/../fixtures/gh-stub/gh" .eval-bin/gh
printf '.eval-bin/\ngh-calls.log\n' >> .git/info/exclude
mkdir -p docs/work/tracking && cp "$here/plan.md" docs/work/tracking/plan.md
