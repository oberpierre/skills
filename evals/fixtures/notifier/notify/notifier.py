from typing import Protocol


class Notifier(Protocol):
    def send(self, customer_id: str, message: str) -> None: ...
