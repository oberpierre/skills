from notify.shipping import on_order_shipped


class Recorder:
    def __init__(self) -> None:
        self.sent: list[tuple[str, str]] = []

    def send(self, customer_id: str, message: str) -> None:
        self.sent.append((customer_id, message))


def test_every_notifier_hears_about_a_shipped_order() -> None:
    a, b = Recorder(), Recorder()
    on_order_shipped([a, b], "c1", "o9")
    assert a.sent == b.sent == [("c1", "Order o9 has shipped.")]
