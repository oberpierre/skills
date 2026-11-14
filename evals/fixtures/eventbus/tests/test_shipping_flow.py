from channels.registry import register_channels
from customers.directory import Directory
from customers.model import Customer
from events.bus import Bus
from orders.model import Order
from orders.service import ship_order


def test_shipping_an_order_reaches_the_mailer(capsys) -> None:
    bus = Bus()
    directory = Directory([Customer("c1", "c1@example.com")])
    register_channels(bus, directory, {"mailer": {"smtp_host": "smtp.test"}})
    ship_order(bus, Order("o1", "c1"), "TRK1")
    assert "o1 is on its way" in capsys.readouterr().out
