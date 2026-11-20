# prefix

**Branch:** `feature/prefix`

Mark every email the shop sends, so customers can filter them.

## Decision log

- `EmailNotifier.send` puts `[shopnotes] ` in front of every message, so `on_order_shipped` and any other notifier stay as they are. Rejected: adding the prefix in `on_order_shipped`, which would also prefix texts.
- The prefix is a fixed string in `EmailNotifier`, not configuration, since the repository serves one shop and nothing else varies it.
- The existing test in `tests/test_shipping.py` keeps passing, since it does not check the email's text.
