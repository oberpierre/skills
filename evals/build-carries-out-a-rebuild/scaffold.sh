#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
cat "$here/gate-log.py" "$here/../fixtures/head-log.py" > .eval-gate-snippet.py
python3 - .eval-gate-snippet.py <<'PY'
import sys
p = "scripts/gate.py"
src = open(p).read()
marker = 'print(f"gate:'
src = src.replace(marker, open(sys.argv[1]).read() + "\n" + marker, 1)
open(p, "w").write(src)
PY
sed -i 's/^tracker: .*/tracker: github/' .agents/config.yml
printf '.eval-rebase.log\n.eval-head.log\n.eval-gate-snippet.py\n.eval-bin/\n.gh-issues/\ngh-calls.log\ngh-state.log\n.gh-plan\n.gh-next\n' >> .git/info/exclude
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"

git checkout -q -b feature/shipping-notes
commit() { git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "$1"; }
plan=docs/work/shipping-notes/plan.md
mkdir -p docs/work/shipping-notes .eval-bin .gh-issues
cp -L "$here/../fixtures/gh-stub/gh" .eval-bin/gh
echo $plan > .gh-plan
# S1 is done and its issue closed. /slice reopened S2's issue when it marked the row for rework.
for n in 1 3; do echo "{\"number\":$n,\"title\":\"Issue $n\",\"body\":\"\",\"state\":\"OPEN\"}" > ".gh-issues/$n.json"; done
echo '{"number":2,"title":"Issue 2","body":"","state":"CLOSED"}' > .gh-issues/2.json
cp "$here/plan.md" $plan

cat > notify/shipping.py <<'PY'
from notify.notifier import Notifier


def on_order_shipped(
    notifiers: list[Notifier], customer_id: str, order_id: str, tracking_url: str | None = None
) -> None:
    message = f"Order {order_id} has shipped."
    if tracking_url:
        message += f" Track it at {tracking_url}."
    for notifier in notifiers:
        notifier.send(customer_id, message)
PY
cat >> tests/test_shipping.py <<'PY'


def test_a_shipped_order_message_links_its_tracking_page() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url="https://t.example/o9")
    assert a.sent == [("c1", "Order o9 has shipped. Track it at https://t.example/o9.")]
PY
sed -i 's/^| \(S1 .*\)| todo |/| \1| done |/' $plan
commit "^ F A shipped order's message ends with its tracking link"

cat > notify/shipping.py <<'PY'
from notify.notifier import Notifier


def on_order_shipped(
    notifiers: list[Notifier],
    customer_id: str,
    order_id: str,
    tracking_url: str | None = None,
    carrier: str | None = None,
) -> None:
    message = f"Order {order_id} has shipped."
    if tracking_url:
        message += f" Track it at {tracking_url}."
    if carrier:
        message += f" via {carrier}."
    for notifier in notifiers:
        notifier.send(customer_id, message)
PY
cat >> tests/test_shipping.py <<'PY'


def test_a_shipped_order_message_names_the_carrier() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url="https://t.example/9", carrier="DHL")
    assert a.sent == [("c1", "Order o9 has shipped. Track it at https://t.example/9. via DHL.")]
PY
sed -i 's/^| \(S2 .*\)| todo |/| \1| done |/' $plan
commit "^ F A shipped order's message names the carrier"

# Unrelated commits after the slice, so a gate on the tip alone cannot stand for every rewritten commit.
cat > tests/test_recorder.py <<'PY'
from tests.test_shipping import Recorder


def test_a_recorder_starts_empty() -> None:
    assert Recorder().sent == []
PY
commit "^ t A recorder starts empty"
cat > tests/test_notifier_base.py <<'PY'
from notify.notifier import Notifier


def test_a_notifier_is_a_class() -> None:
    assert isinstance(Notifier, type)
PY
commit "^ t A notifier is a class"

sed -i 's/^\(| S2 .*\)| done | | #3 |/\1| rework | Rebuild: the carrier follows the tracking link as ` Carrier: <carrier>.`, replacing the ` via <carrier>.` that was built. | #3 |/' $plan
commit "Mark S2 for rework"
rm -f .eval-rebase.log
