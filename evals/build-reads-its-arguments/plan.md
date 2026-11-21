# shipping-notes

**Branch:** `feature/shipping-notes`

Shipped-order messages link the tracking page and say which carrier has the parcel, and an email names its sender.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | A shipped order's message ends with its tracking link when the order has one | `test_a_shipped_order_message_links_its_tracking_page`, through `on_order_shipped` | none | todo | |
| S2 | A shipped order's message names the carrier after the tracking link | `test_a_shipped_order_message_names_the_carrier`, through `on_order_shipped` | S1 | todo | |
| S3 | An email names its sender when the notifier has one | `test_an_email_names_its_sender_when_it_has_one` in `tests/test_email.py`, through `EmailNotifier.send` | none | todo | |

## Decision log

- `on_order_shipped` takes the tracking link as an optional keyword argument, `tracking_url`, defaulting to none, and the carrier as `carrier`.
- `EmailNotifier` takes an optional keyword argument, `sender`, defaulting to none. With a sender, the printed line reads `email via <smtp_host> from <sender> to <customer_id>: <message>`, and without one it stays exactly as it is.
