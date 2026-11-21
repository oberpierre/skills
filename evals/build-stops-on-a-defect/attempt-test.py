import contextlib
import io

from notify.email import EmailNotifier


def test_an_email_names_its_sender_when_it_has_one() -> None:
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        EmailNotifier("smtp.example.com", sender="shop@example.com").send("c-7", "Your order shipped")
    assert out.getvalue().strip() == "email via smtp.example.com from shop@example.com to c-7: Your order shipped"
