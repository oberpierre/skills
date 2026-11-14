from notify.notifier import Notifier


class EmailNotifier(Notifier):
    def __init__(self, smtp_host: str) -> None:
        self.smtp_host = smtp_host

    def send(self, customer_id: str, message: str) -> None:
        print(f"email via {self.smtp_host} to {customer_id}: {message}")
