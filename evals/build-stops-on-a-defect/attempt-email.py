from notify.notifier import Notifier


class EmailNotifier(Notifier):
    def __init__(self, smtp_host: str, *, sender: str | None = None) -> None:
        self.smtp_host = smtp_host
        self.sender = sender

    def send(self, customer_id: str, message: str) -> None:
        origin = f" from {self.sender}" if self.sender else ""
        print(f"email via {self.smtp_host} to {customer_id}{origin}: {message}")
