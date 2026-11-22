#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
cp "$here/e2e.py" scripts/e2e.py
echo "e2e: python3 scripts/e2e.py" >> .agents/config.yml
sed -i 's/^tracker: .*/tracker: github/' .agents/config.yml
mkdir -p .eval-bin && cp -L "$here/../fixtures/gh-stub/gh" .eval-bin/gh
printf '.eval-e2e.log\n.eval-bin/\n.gh-issues/\ngh-calls.log\n.gh-next\n' >> .git/info/exclude
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
"$here/../fixtures/log-commits.sh"
mkdir -p .gh-issues docs/work/shipping-notes && cp "$here/plan.md" docs/work/shipping-notes/plan.md
for n in 1 2 3 4; do
  echo "{\"number\":$n,\"title\":\"Issue $n\",\"body\":\"\",\"state\":\"OPEN\"}" > ".gh-issues/$n.json"
done
