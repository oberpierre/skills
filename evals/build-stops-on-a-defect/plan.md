# shipping-notes

**Branch:** `feature/shipping-notes`

An email names its sender.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | An email names its sender when the notifier has one | `test_an_email_names_its_sender_when_it_has_one` in `tests/test_email.py`, through `EmailNotifier.send` | none | todo | |

## Decision log

- `EmailNotifier` takes an optional keyword argument, `sender`, defaulting to none. With a sender, the printed line reads `email via <smtp_host> from <sender> to <customer_id>: <message>`, and without one it stays exactly as it is.
- The acceptance test builds `EmailNotifier("smtp.example.com", sender="shop@example.com")`, sends `c-7` and `Your order shipped`, and asserts the printed line equals `email via smtp.example.com from shop@example.com to c-7: Your order shipped`.
