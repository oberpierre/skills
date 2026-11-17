# sms

**Branch:** `feature/sms`

Text customers when their order ships, alongside the existing email.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | `SmsNotifier.send` texts the customer through Twilio from the configured `from_number` | `test_send_texts_the_customer`, through `SmsNotifier.send` with a recording Twilio client | none | todo | |
| S2 | `phone_for(customer_id)` returns the customer's phone number from the customer store, or `None` | `test_phone_for_reads_the_store`, through `phone_for` with a store holding one customer | none | todo | |
| S3 | A customer without a phone number gets no text, and nothing fails | `test_no_phone_no_text`, through `SmsNotifier.send` with a `phone_for` returning `None` | S1, S2 | todo | |

## Decision log

- Texts go out through Twilio, as `config/channels.toml` already provisions, with the sender number from `from_number`.
- SMS is a `SmsNotifier` beside `EmailNotifier`, implementing the existing `Notifier` protocol, so `on_order_shipped` needs no change of its own.
- The phone number comes from a `phone_for(customer_id)` function passed to `SmsNotifier`.
- A customer without a phone number gets no text, and nothing fails.
