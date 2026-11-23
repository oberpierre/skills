import socket


def test_the_carrier_sandbox_answers() -> None:
    socket.create_connection(("127.0.0.1", 9), timeout=2).close()
