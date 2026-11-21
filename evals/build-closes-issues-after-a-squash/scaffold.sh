#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
sed -i 's/^tracker: .*/tracker: github/' .agents/config.yml
printf '.eval-bin/\n.gh-issues/\ngh-calls.log\ngh-state.log\n.gh-plan\n.gh-next\n' >> .git/info/exclude
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"

git checkout -q -b feature/shipping-notes
commit() { git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "$1"; }
mkdir -p docs/work/shipping-notes
cp -RL "$here/bin" .eval-bin
mkdir -p .gh-issues
echo docs/work/shipping-notes/plan.md > .gh-plan
# /slice reopened both issues when it marked the rows for rework.
for n in 1 2 3; do echo "{\"number\":$n,\"title\":\"Issue $n\",\"body\":\"\",\"state\":\"OPEN\"}" > ".gh-issues/$n.json"; done
cp "$here/plan.md" docs/work/shipping-notes/plan.md

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


def test_a_message_without_a_link_is_unchanged() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url=None)
    assert a.sent == [("c1", "Order o9 has shipped.")]
PY
sed -i 's/^| \(S1 .*\)| todo |/| \1| done |/' docs/work/shipping-notes/plan.md
commit "^ F A shipped order's message ends with its tracking link"

cat > notify/email.py <<'PY'
from notify.notifier import Notifier


class EmailNotifier(Notifier):
    def __init__(self, smtp_host: str, sender: str | None = None) -> None:
        self.smtp_host = smtp_host
        self.sender = sender

    def send(self, customer_id: str, message: str) -> None:
        origin = f" from {self.sender}" if self.sender else ""
        print(f"email via {self.smtp_host}{origin} to {customer_id}: {message}")
PY
cat > tests/test_email.py <<'PY'
import contextlib
import io

from notify.email import EmailNotifier


def test_an_email_names_its_sender_when_it_has_one() -> None:
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        EmailNotifier("smtp.example", sender="shop@example.com").send("c1", "hi")
    assert out.getvalue() == "email via smtp.example from shop@example.com to c1: hi\n"
PY
sed -i 's/^| \(S2 .*\)| todo |/| \1| done |/' docs/work/shipping-notes/plan.md
commit "^ F An email names its sender when the notifier has one"

# Unrelated commits after the slices, so a gate on the tip alone cannot stand for every rewritten commit.
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

# /slice marks both rows and commits nothing that rewrites history.
sed -i 's/^\(| S1 .*\)| done | | #2 |/\1| rework | Squash S2 into S1 as one slice | #2 |/; s/^\(| S2 .*\)| done | | #3 |/\1| rework | Squash into S1 | #3 |/' docs/work/shipping-notes/plan.md
commit "Mark S1 and S2 for rework"
