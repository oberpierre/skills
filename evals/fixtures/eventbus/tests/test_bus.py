from events.bus import Bus


def test_publish_reaches_every_subscriber_of_the_type() -> None:
    bus, seen = Bus(), []
    bus.subscribe(int, seen.append)
    bus.subscribe(int, seen.append)
    bus.publish(3)
    assert seen == [3, 3]
