from events.bus import Bus
from events.types import OrderRefunded
from orders.model import Order


def refund_order(bus: Bus, order: Order, amount_cents: int) -> None:
    bus.publish(OrderRefunded(order.order_id, order.customer_id, amount_cents))
