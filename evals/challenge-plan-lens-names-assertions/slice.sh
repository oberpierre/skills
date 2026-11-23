#!/usr/bin/env bash
# Commits slice S1 as one commit on top of the plan: the test pins who is texted, not from which number.
set -euo pipefail
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


def test_send_texts_the_customer() -> None:
    client = RecordingClient()
    SmsNotifier(client, "+15550100", lambda _id: "+4915123").send("c1", "Order o9 has shipped.")
    assert client.texts[0].to == "+4915123"
    assert client.texts[0].body == "Order o9 has shipped."
EOF
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "SmsNotifier texts the customer"
