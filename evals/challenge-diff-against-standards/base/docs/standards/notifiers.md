# Notifier standards

- `send` never raises. A notifier that fails logs the failure with `logging.getLogger(__name__)` and returns, so that one channel failing never stops the customer hearing through the others.
- A notifier holds no network client at import time; it opens one in `send`.
