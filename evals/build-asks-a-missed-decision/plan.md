# opt-outs

**Branch:** `feature/opt-outs`

A customer who opted out of shipping messages does not get one.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | `on_order_shipped` sends no shipping message to a customer who has opted out of them, and still sends it to every other customer | `test_an_opted_out_customer_hears_nothing_about_a_shipped_order` in `tests/test_shipping.py`, through `on_order_shipped` | none | todo | |

## Decision log

- An opt-out covers shipping messages on every channel, so it is per customer and not per notifier.
- `tests/test_shipping.py::test_every_notifier_hears_about_a_shipped_order` already pins the shipped message and stays exactly as it is.
