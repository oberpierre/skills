from dataclasses import dataclass


@dataclass(frozen=True)
class OrderPlaced:
    order_id: str
    customer_id: str


@dataclass(frozen=True)
class OrderShipped:
    order_id: str
    customer_id: str
    tracking_number: str


@dataclass(frozen=True)
class OrderRefunded:
    order_id: str
    customer_id: str
    amount_cents: int
