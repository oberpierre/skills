# shopnotes

- Run the tests with `pytest`.
- Nothing under `notify/` reads environment variables. A notifier gets its settings from `config/channels.toml`, passed to its constructor by the caller.
- See `.agents/config.yml` for the project's standards.
