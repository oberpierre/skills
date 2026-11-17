# prefix

**Branch:** `feature/prefix`
**Issue:** #1

Mark every email the shop sends, so customers can filter them.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note | Issue |
|---|---|---|---|---|---|---|
| S1 | The message of every email `EmailNotifier` sends starts with `[shopnotes] ` | `test_email_starts_with_the_shop_prefix`, through `on_order_shipped` for order `o1` with an `EmailNotifier` in its notifiers, asserting it prints `email via <host> to <customer>: [shopnotes] Order o1 has shipped.` | none | todo | | #2 |
| S2 | Notifiers other than `EmailNotifier` get the shipping message without the prefix | `test_other_notifiers_get_no_prefix`, through `on_order_shipped` for order `o1` with a recording notifier beside an `EmailNotifier`, asserting the recorder got exactly `Order o1 has shipped.` | S1 | todo | | #3 |

## Decision log

- `EmailNotifier.send` puts `[shopnotes] ` in front of every message, so `on_order_shipped` and any other notifier stay as they are. Rejected: adding the prefix in `on_order_shipped`, which would also prefix texts.
- The prefix is a fixed string in `EmailNotifier`, not configuration, since the repository serves one shop and nothing else varies it.
- The existing test in `tests/test_shipping.py` keeps passing, since it does not check the email's text.
