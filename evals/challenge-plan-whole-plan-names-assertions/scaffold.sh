#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
mkdir -p docs/work/sms && cp "$here/plan.md" docs/work/sms/plan.md
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Plan SMS notifications"
commit() { git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "$1"; }
cat > notify/sms.py <<'EOF'
from dataclasses import dataclass
from typing import Callable

from notify.notifier import Notifier


@dataclass
class Text:
    to: str
    from_number: str
    body: str


class SmsNotifier(Notifier):
    def __init__(self, client, from_number: str, phone_for: Callable[[str], str]) -> None:
        self.client = client
        self.from_number = from_number
        self.phone_for = phone_for

    def send(self, customer_id: str, message: str) -> None:
        self.client.send(Text(self.phone_for(customer_id), self.from_number, message))
EOF
cat > tests/test_sms.py <<'EOF'
from notify.sms import SmsNotifier


class RecordingClient:
    def __init__(self) -> None:
        self.texts = []

    def send(self, text) -> None:
        self.texts.append(text)


def test_send_texts_the_customer_from_the_configured_number() -> None:
    client = RecordingClient()
    SmsNotifier(client, "+15550100", lambda _id: "+4915123").send("c1", "Order o9 has shipped.")
    assert client.texts[0].to == "+4915123"
    assert client.texts[0].from_number == "+15550100"
    assert client.texts[0].body == "Order o9 has shipped."
EOF
commit "SmsNotifier texts the customer from the configured number"
python3 - <<'EOF'
p = "notify/sms.py"
s = open(p).read()
s = s.replace("        self.phone_for = phone_for\n", "        self.phone_for = phone_for\n        self.skipped: list[str] = []\n")
s = s.replace("        self.client.send(Text(self.phone_for(customer_id), self.from_number, message))\n",
"        number = self.phone_for(customer_id)\n        if not number:\n            self.skipped.append(customer_id)\n            return\n        self.client.send(Text(number, self.from_number, message))\n")
open(p, "w").write(s)
EOF
cat >> tests/test_sms.py <<'EOF'


def test_send_texts_nothing_without_a_number() -> None:
    client = RecordingClient()
    SmsNotifier(client, "+15550100", lambda _id: "").send("c2", "Order o9 has shipped.")
    assert client.texts == []
EOF
commit "SmsNotifier texts nothing when the customer has no number"
