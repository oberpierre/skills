#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
cp -RL "$(dirname "$0")/bin" .eval-bin
git remote add origin git@github.com:eval/shopnotes.git
mkdir -p docs/work/prefix .agents && cp "$(dirname "$0")/plan.md" docs/work/prefix/plan.md
printf 'tracker: github\n' > .agents/config.yml
printf '.eval-bin/\n.gh-issues/\ngh-calls.log\n.gh-next\n' > .gitignore
echo 3 > .gh-next
mkdir -p .gh-issues
issue() { python3 -I -c 'import json,sys; print(json.dumps({"number": int(sys.argv[1]), "title": sys.argv[2], "body": sys.argv[3], "state": "OPEN"}))' "$@" > ".gh-issues/$1.json"; }
issue 1 "Prefix the shop's emails" $'Customers can filter the shop\'s emails, because every one starts with [shopnotes].\n\nFeature: prefix'
issue 2 "Start every email with the shop prefix" $'Every email the shop sends starts with [shopnotes], so customers can filter them.\n\nAcceptance test: `test_email_starts_with_the_shop_prefix`, through `on_order_shipped` for order `o1` with an `EmailNotifier` in its notifiers\nFeature: prefix\nSlice: S1'
issue 3 "Keep other notifiers unprefixed" $'Only emails carry the prefix: other notifiers get the shipping message as it was.\n\nAcceptance test: `test_other_notifiers_get_no_prefix`, through `on_order_shipped` with a recording notifier beside an `EmailNotifier`\nFeature: prefix\nSlice: S2'
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan the email prefix and mirror it"
