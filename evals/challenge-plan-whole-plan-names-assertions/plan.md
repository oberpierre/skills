# sms

**Branch:** `feature/sms`

Text customers when their order ships, alongside the existing email.

## Slices

| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | `SmsNotifier.send` texts the customer's number from the configured `from_number` | `test_send_texts_the_customer_from_the_configured_number`, through `SmsNotifier.send` with a recording client | none | done | |
| S2 | `SmsNotifier.send` texts nothing when the customer has no number, and counts that customer in `skipped` | `test_send_texts_nothing_without_a_number`, through `SmsNotifier.send` with a recording client | S1 | done | |

## Decision log

- Texts go out through a client the notifier is given, with the sender number from `from_number`.
- SMS is a `SmsNotifier` beside `EmailNotifier`, implementing the existing `Notifier` protocol.
