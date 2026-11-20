# sms

**Branch:** `feature/sms`

Text customers when their order ships, alongside the existing email.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | `SmsNotifier.send` texts the customer's number through Twilio, from the configured `from_number` | `test_send_texts_the_customer`, through `SmsNotifier.send` with a recording Twilio client | none | todo | |

## Decision log

- Texts go out through Twilio, as `config/channels.toml` already provisions, with the sender number from `from_number`.
- SMS is a `SmsNotifier` beside `EmailNotifier`, implementing the existing `Notifier` protocol.
