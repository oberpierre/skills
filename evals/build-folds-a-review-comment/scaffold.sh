#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
python3 - "$here/gate-log.py" <<'PY'
import sys
p = "scripts/gate.py"
src = open(p).read()
marker = 'print(f"gate:'
src = src.replace(marker, open(sys.argv[1]).read() + "\n" + marker, 1)
open(p, "w").write(src)
PY
echo ".eval-rebase.log" >> .git/info/exclude
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"

git checkout -q -b feature/shipping-notes
commit() { git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "$1"; }
mkdir -p docs/work/shipping-notes
cp "$here/plan.md" docs/work/shipping-notes/plan.md

# S2 is built first, so S1's commits come after S2's in history.
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

# S1 is two commits, and the defect sits in the first.
cat > notify/shipping.py <<'PY'
from notify.notifier import Notifier


def on_order_shipped(
    notifiers: list[Notifier], customer_id: str, order_id: str, tracking_url: str | None = None
) -> None:
    message = f"Order {order_id} has shipped."
    if tracking_url:
        message += f" Track it at {tracking_url}"
    for notifier in notifiers:
        notifier.send(customer_id, message)
PY
cat >> tests/test_shipping.py <<'PY'


def test_a_shipped_order_message_links_its_tracking_page() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url="https://t.example/o9")
    assert a.sent == [("c1", "Order o9 has shipped. Track it at https://t.example/o9")]
PY
commit "^ F A shipped order's message ends with its tracking link"
cat > tests/test_plain_message.py <<'PY'
from notify.shipping import on_order_shipped
from tests.test_shipping import Recorder


def test_a_message_without_a_link_is_unchanged() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url=None)
    assert a.sent == [("c1", "Order o9 has shipped.")]
PY
sed -i 's/^| \(S1 .*\)| todo |/| \1| done |/' docs/work/shipping-notes/plan.md
commit "^ t A message without a link stays exactly as it is"
rm -f .eval-rebase.log
