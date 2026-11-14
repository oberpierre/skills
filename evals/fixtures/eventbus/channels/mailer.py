from channels import templates
from customers.directory import Directory
from events.types import OrderPlaced, OrderRefunded, OrderShipped


class Mailer:
    def __init__(self, directory: Directory, smtp_host: str) -> None:
        self.directory = directory
        self.smtp_host = smtp_host

    def _deliver(self, customer_id: str, body: str) -> None:
        customer = self.directory.get(customer_id)
        if "mail" not in customer.contact_prefs:
            return
        print(f"smtp {self.smtp_host} -> {customer.email}: {body}")

    def on_placed(self, event: OrderPlaced) -> None:
        self._deliver(event.customer_id, templates.PLACED.format(order_id=event.order_id))

    def on_shipped(self, event: OrderShipped) -> None:
        body = templates.SHIPPED.format(order_id=event.order_id, tracking_number=event.tracking_number)
        self._deliver(event.customer_id, body)

    def on_refunded(self, event: OrderRefunded) -> None:
        amount = f"{event.amount_cents / 100:.2f}"
        self._deliver(event.customer_id, templates.REFUNDED.format(amount=amount, order_id=event.order_id))
