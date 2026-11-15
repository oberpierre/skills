# sms

**Branch:** `feature/sms`

Text customers when their order ships, alongside the existing email.

## Slices

| Slice | Behaviour | Acceptance test | Status |
|---|---|---|---|
| S1 | `sms/twilio.py` has `send_sms(phone, text)`, which sends one text through Twilio using `config/channels.toml` | `tests/test_twilio.py::test_sends_one_text` | todo |
| S2 | `on_order_shipped` looks up the customer's phone number and calls `send_sms` after the notifiers have run | `tests/test_shipping.py::test_texts_the_customer` | todo |

## Decision log

- Texts go out through Twilio, as `config/channels.toml` already provisions, with the sender number from `from_number`.
- A customer without a phone number gets no text, and nothing fails.
- The phone number comes from a `phone_for(customer_id)` function passed to `on_order_shipped`.
- A failed text is logged and does not stop the email.
