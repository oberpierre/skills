import sys

root, which = sys.argv[1], sys.argv[2]
HEAD = '''from notify.notifier import Notifier


def on_order_shipped(
    notifiers: list[Notifier],
    customer_id: str,
    order_id: str,
    tracking_url: str | None = None,
%(param)s) -> None:
    message = f"Order {order_id} has shipped."
    if tracking_url:
        message += f" Track it at {tracking_url}."
%(carrier)s    for notifier in notifiers:
        notifier.send(customer_id, message)
'''
if which == "s1":
    code = HEAD % {"param": "", "carrier": ""}
    test = '''

def test_a_shipped_order_message_links_its_tracking_page() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url="https://t.example/9")
    assert a.sent == [("c1", "Order o9 has shipped. Track it at https://t.example/9.")]
'''
else:
    code = HEAD % {
        "param": "    carrier: str | None = None,\n",
        "carrier": '    if carrier:\n        message += f" via {carrier}."\n',
    }
    test = '''

def test_a_shipped_order_message_names_the_carrier() -> None:
    a = Recorder()
    on_order_shipped([a], "c1", "o9", tracking_url="https://t.example/9", carrier="DHL")
    assert a.sent == [("c1", "Order o9 has shipped. Track it at https://t.example/9. via DHL.")]
'''
open(f"{root}/notify/shipping.py", "w").write(code)
with open(f"{root}/tests/test_shipping.py", "a") as f:
    f.write(test)
