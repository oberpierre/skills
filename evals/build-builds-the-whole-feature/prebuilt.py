import sys

root = sys.argv[1]
open(f"{root}/notify/shipping.py", "w").write('''from notify.notifier import Notifier


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
''')
with open(f"{root}/tests/test_shipping.py", "a") as f:
    f.write('''

def test_a_shipped_order_message_links_its_tracking_page() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url="https://t.example/9")
    assert a.sent == [("c1", "Order o9 has shipped. Track it at https://t.example/9.")]


def test_a_shipped_order_message_names_the_carrier() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url="https://t.example/9", carrier="DHL")
    assert a.sent == [("c1", "Order o9 has shipped. Track it at https://t.example/9. via DHL.")]
''')
