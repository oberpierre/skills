# digest

Send each customer one daily email listing the orders that shipped that day, instead of an email per order.

## Decision log

- The digest is a `DigestNotifier` implementing the existing `Notifier` protocol, collecting shipped orders per customer instead of sending at once.
- A scheduled `send_digests()` sends one email per customer with orders collected since the last run, through the existing `EmailNotifier` transport.
- A customer with no shipped orders that day gets no email.
- Collected orders are kept in memory. A restart before `send_digests()` loses them, which is accepted for now.
