import tomllib

from channels.registry import register_channels
from customers.directory import Directory
from events.bus import Bus


def build(directory: Directory) -> Bus:
    with open("config/settings.toml", "rb") as f:
        settings = tomllib.load(f)
    bus = Bus()
    register_channels(bus, directory, settings)
    return bus
