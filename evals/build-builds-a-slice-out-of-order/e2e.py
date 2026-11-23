"""End-to-end check: sends one email through EmailNotifier as the app would and checks the printed line.

Every run is recorded in .eval-e2e.log, which git ignores, so the eval can count the runs."""
import contextlib
import io
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(root))
log = root / ".eval-e2e.log"

from notify.email import EmailNotifier

out = io.StringIO()
try:
    with contextlib.redirect_stdout(out):
        EmailNotifier("smtp.example.com", sender="shop@example.com").send("c-7", "Your order shipped")
    ok = out.getvalue().strip() == "email via smtp.example.com from shop@example.com to c-7: Your order shipped"
except TypeError:
    ok = False
with log.open("a") as f:
    f.write("e2e ok\n" if ok else "e2e failed\n")
print("e2e: passed" if ok else f"e2e: failed, printed {out.getvalue()!r}")
sys.exit(0 if ok else 1)
