# oberpierre-skills

Instructions for developing this plugin. They sit in `.claude/` because the plugin validator rejects a `CLAUDE.md` at the plugin root, and Claude Code loads them from here as well. The design is in `docs/adr/`, the vocabulary in `GLOSSARY.md`. Work in progress has a plan at `docs/work/<feature>/plan.md`.

- **Gate:** `scripts/gate.sh`, run before every commit by the hook `scripts/gate.sh --install` sets up.
- **Commits:** `arlo-features` as ADR 0003 describes, one behaviour per commit (ADR 0002).
- **Evals:** a skill's behaviour is pinned by eval cases in `evals/<skill>-*`, run with `claude plugin eval . --case '<case>' --allow-tools Write Edit --scaffold --trust-plugin --no-publish --threshold 0.67`. Run a new case red against the skill before writing the text that should turn it green.

## Gotchas

Budget: 40 lines. Each entry is something that cost a round to find out.

- A case is a `case.yaml` with `schema_version: "1.0"`. Its `scaffold_script` must name a file inside the case folder, so each case has a one-line `scaffold.sh` calling `evals/fixtures/scaffold.sh <fixture>`, which runs in the session's working directory.
- Write, Edit and Bash exist in an eval session only when granted with `--allow-tools`. Without the grant, a grader that the agent writes nothing passes because it cannot. Granting Bash needs `bubblewrap` and `socat` installed, or the run refuses to start.
- `--case` takes one pattern. Given twice, only the last runs. `--keep-temp` keeps the traces a grader's verdict needs to be checked against.
- A case with a `history_file` resumes a recorded session, which carries the skill text expanded when it was recorded. The run without the plugin resumes the same text, so such a case measures no lead. The gate fails when the recorded text differs from `SKILL.md`. `python3 evals/refresh-history.py` rewrites it.
- A resume walks `parentUuid` back from the last entry and stops silently at a missing parent. Removing entries from a recording drops everything before the gap, the skill text included, and the agent then works without it. `refresh-history.py` relinks the chain.
- A raw session recording stores the full API request, the user's email address included. Keep only the `user` and `assistant` entries before committing one.
- Resuming a `history_file` writes a session file named after its ID into the case folder. `.gitignore` covers it.
- An `llm` grader with a double negative in its criterion judged the wrong thing. Where the behaviour has a fixed form, a `regex` or `tool_used` grader is checked offline first against saved traces and is then trusted over a judge.
- Claude already looks facts up instead of asking, and maps an idea onto an existing mechanism in a 20-file repository, without being told. Run the case red first, and write a skill line only for what it does not do.
- Asking the model which skills it has is no test of whether a plugin loaded, because `disable-model-invocation: true` hides a user-invoked skill from the model. Type the command in a fresh session and check that the transcript shows it expanded.
- `CLAUDE_CODE_PLUGIN_DIRS` loads a plugin only from the process environment. Set under `env` in a settings file, it does nothing.
