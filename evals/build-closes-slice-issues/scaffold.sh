#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
sed -i 's/^tracker: .*/tracker: github/' .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
cp -RL "$here/bin" .eval-bin
printf '.eval-bin/\n.gh-issues/\ngh-calls.log\n.gh-next\n' >> .git/info/exclude
mkdir -p .gh-issues docs/work/tracking && cp "$here/plan.md" docs/work/tracking/plan.md
for n in 1 2 3; do
  echo "{\"number\":$n,\"title\":\"Issue $n\",\"body\":\"\",\"state\":\"OPEN\"}" > ".gh-issues/$n.json"
done
