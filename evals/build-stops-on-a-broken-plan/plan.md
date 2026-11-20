# tracking

A shipped order's message links the carrier's tracking page, and a delivered one says so.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | A shipped order's message ends with its tracking link when the order has one | `test_a_shipped_order_message_links_its_tracking_page`, through `on_order_shipped` | none | todo | |
| S2 | A delivered order's message says it was delivered | `test_a_delivered_order_message_says_so`, through `on_order_delivered` | S9 | todo | |
| S3 | The shipped message names the carrier | `test_a_shipped_order_message_names_the_carrier`, through `on_order_shipped` | S1 | rework | |

## Decision log

- `on_order_shipped` takes the tracking link as an optional keyword argument, `tracking_url`, defaulting to none, so existing callers keep working.
