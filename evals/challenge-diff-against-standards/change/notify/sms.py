import os
import urllib.request

from notify.notifier import Notifier


class SmsNotifier(Notifier):
    def __init__(self, from_number: str, retries: int = 3) -> None:
        self.from_number = from_number
        self.token = os.environ["TWILIO_AUTH_TOKEN"]

    def send(self, customer_id: str, message: str) -> None:
        request = urllib.request.Request(
            "https://api.twilio.example/messages",
            data=f"from={self.from_number}&to={customer_id}&body={message}".encode(),
            headers={"Authorization": f"Bearer {self.token}"},
        )
        with urllib.request.urlopen(request) as response:
            if response.status != 201:
                raise RuntimeError(f"sms to {customer_id} failed: {response.status}")
