from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class Order:
    order_id: str
    customer_id: str
    items: list[str] = field(default_factory=list)
    shipped_at: datetime | None = None
    tracking_number: str | None = None
