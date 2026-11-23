# tracking

**Branch:** `feature/tracking`

A shipped order's message links the carrier's tracking page.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note | Issue |
|---|---|---|---|---|---|---|
| S1 | A shipped order's message ends with its tracking link when the order has one | `test_a_shipped_order_message_links_its_tracking_page`, through `on_order_shipped` | none | todo | | |

## Decision log

- `on_order_shipped` takes the tracking link as an optional keyword argument, `tracking_url`, defaulting to none.
