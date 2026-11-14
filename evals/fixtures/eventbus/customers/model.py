from dataclasses import dataclass, field


@dataclass
class Customer:
    customer_id: str
    email: str
    phone: str | None = None
    contact_prefs: set[str] = field(default_factory=lambda: {"mail"})
