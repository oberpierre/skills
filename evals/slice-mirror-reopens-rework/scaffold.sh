#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/../fixtures/scaffold.sh" notifier
git="git -c user.name=eval -c user.email=eval@example.invalid"
$git branch -M main
git remote add origin git@github.com:eval/shopnotes.git
git update-ref refs/remotes/origin/main main
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
$git checkout -q -b feature/prefix
cp -RL "$(dirname "$0")/bin" .eval-bin
mkdir -p docs/work/prefix .agents && cp "$(dirname "$0")/plan.md" docs/work/prefix/plan.md
printf 'tracker: github\n' > .agents/config.yml
printf '.eval-bin/\n.gh-issues/\ngh-calls.log\n.gh-next\n' > .gitignore
echo 3 > .gh-next
mkdir -p .gh-issues
issue() { python3 -I -c 'import json,sys; print(json.dumps({"number": int(sys.argv[1]), "title": sys.argv[2], "body": sys.argv[3], "state": sys.argv[4]}))' "$@" > ".gh-issues/$1.json"; }
issue 1 "Prefix the shop's emails" $'Customers can filter the shop\'s emails, because every one starts with [shopnotes].\n\nFeature: prefix' OPEN
issue 2 "Start every email with the shop prefix" $'Every email the shop sends starts with [shopnotes], so customers can filter them.\n\nAcceptance test: `test_email_starts_with_the_shop_prefix`, through `on_order_shipped` for order `o1` with an `EmailNotifier` in its notifiers\nFeature: prefix\nSlice: S1' OPEN
issue 3 "Keep other notifiers unprefixed" $'Only emails carry the prefix: other notifiers get the shipping message as it was.\n\nAcceptance test: `test_other_notifiers_get_no_prefix`, through `on_order_shipped` with a recording notifier beside an `EmailNotifier`\nFeature: prefix\nSlice: S2' OPEN
git add -A && $git commit -q -m "Plan the email prefix and mirror it"
# S1, built with a test that only checks the prefix is somewhere in the email.
sed -i 's/{message}")/[shopnotes] {message}")/' notify/email.py
cat > tests/test_prefix.py <<'PY'
from notify.email import EmailNotifier
from notify.shipping import on_order_shipped


def test_email_starts_with_the_shop_prefix(capsys) -> None:
    on_order_shipped([EmailNotifier("smtp.example")], "c1", "o1")
    assert "[shopnotes]" in capsys.readouterr().out
PY
sed -i 's/^\(| S1 |.*| none | \)todo\( | | #2 |\)$/\1done\2/' docs/work/prefix/plan.md
issue 2 "Start every email with the shop prefix" "$(python3 -I -c 'import json; print(json.load(open(".gh-issues/2.json"))["body"])')" CLOSED
$git add -A && $git commit -q -m "Prefix every email the shop sends"
