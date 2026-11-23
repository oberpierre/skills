# shipping-notes

**Branch:** `feature/shipping-notes`
**Issue:** #1

Shipped-order messages link the tracking page and say which carrier has the parcel.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note | Issue |
|---|---|---|---|---|---|---|
| S1 | A shipped order's message ends with its tracking link when the order has one | `test_a_shipped_order_message_links_its_tracking_page`, through `on_order_shipped` | none | todo | | #2 |
| S2 | A shipped order's message names the carrier after the tracking link | `test_a_shipped_order_message_names_the_carrier`, through `on_order_shipped` | S1 | todo | | #3 |

## Decision log

- `on_order_shipped` takes the tracking link as an optional keyword argument, `tracking_url`, defaulting to none, and the carrier as `carrier`.
