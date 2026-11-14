from customers.model import Customer


class Directory:
    def __init__(self, customers: list[Customer]) -> None:
        self._by_id = {c.customer_id: c for c in customers}

    def get(self, customer_id: str) -> Customer:
        return self._by_id[customer_id]
