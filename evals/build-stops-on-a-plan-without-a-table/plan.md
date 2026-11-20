# tracking

**Branch:** `feature/tracking`

A shipped order's message links the carrier's tracking page.

## Decision log

- `on_order_shipped` takes the tracking link as an optional keyword argument, `tracking_url`, defaulting to none.
