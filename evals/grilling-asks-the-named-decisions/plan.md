# sms

Text customers when their order ships, alongside the existing email.

## Decision log

- Texts go out through Twilio, as `config/channels.toml` already provisions, with the sender number from `from_number`.
- SMS is a `SmsNotifier` beside `EmailNotifier`, implementing the existing `Notifier` protocol, so `on_order_shipped` needs no change of its own.
- The phone number comes from a `phone_for(customer_id)` function passed to `SmsNotifier`.
- A customer without a phone number gets no text, and nothing fails.
- A failed text is logged and does not stop the other notifiers.
- Twilio reports each text's delivery to a status webhook, and a text Twilio reports as undelivered is sent again by email.
