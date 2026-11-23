# order-numbers

**Branch:** `feature/order-numbers`

A notifier hears which order a message is about.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | `Notifier.send` takes the order id as a required third parameter, and `on_order_shipped` passes it | `test_a_shipped_order_reaches_every_notifier_with_its_order_id` in `tests/test_shipping.py`, through `on_order_shipped` | none | todo | |

## Decision log

- `Notifier.send(customer_id, message, order_id)` takes `order_id` as a required positional parameter, with no default, so no notifier can forget it.
- `tests/test_shipping.py::test_every_notifier_hears_about_a_shipped_order` and its `Recorder` already pin the shipped message and stay exactly as they are.
