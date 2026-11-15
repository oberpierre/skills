# sms

**Branch:** `feature/sms`

Text customers when their order ships, alongside the existing email.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | When an order ships, a customer with a phone number gets a text through Twilio from the configured `from_number` | `test_texts_the_customer`, through `on_order_shipped` with an `SmsNotifier` in its notifiers | none | done | |
| S2 | A customer without a phone number gets no text, and the other notifiers still hear about the order | `test_no_phone_no_text`, through `on_order_shipped` with `phone_for` returning `None` | S1 | todo | |

## Decision log

- Texts go out through Twilio, as `config/channels.toml` already provisions, with the sender number from `from_number`.
- SMS is a `SmsNotifier` beside `EmailNotifier`, implementing the existing `Notifier` protocol, so `on_order_shipped` needs no change of its own.
- The phone number comes from a `phone_for(customer_id)` function passed to `SmsNotifier`.
- A customer without a phone number gets no text, and nothing fails.
- A failed text is logged and does not stop the other notifiers.
- A customer who has opted out of texts gets none. `SmsNotifier` is given an `opted_out(customer_id)` function beside `phone_for`.
