from channels.mailer import Mailer
from customers.directory import Directory
from events.bus import Bus
from events.types import OrderPlaced, OrderRefunded, OrderShipped


def register_channels(bus: Bus, directory: Directory, settings: dict) -> dict[str, object]:
    mailer = Mailer(directory, settings["mailer"]["smtp_host"])
    bus.subscribe(OrderPlaced, mailer.on_placed)
    bus.subscribe(OrderShipped, mailer.on_shipped)
    bus.subscribe(OrderRefunded, mailer.on_refunded)
    return {"mailer": mailer}
