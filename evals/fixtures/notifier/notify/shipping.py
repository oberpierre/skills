from notify.notifier import Notifier


def on_order_shipped(notifiers: list[Notifier], customer_id: str, order_id: str) -> None:
    for notifier in notifiers:
        notifier.send(customer_id, f"Order {order_id} has shipped.")
