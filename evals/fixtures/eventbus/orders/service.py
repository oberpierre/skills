from datetime import datetime, timezone

from events.bus import Bus
from events.types import OrderShipped
from orders.model import Order


def ship_order(bus: Bus, order: Order, tracking_number: str) -> None:
    order.shipped_at = datetime.now(timezone.utc)
    order.tracking_number = tracking_number
    bus.publish(OrderShipped(order.order_id, order.customer_id, tracking_number))
