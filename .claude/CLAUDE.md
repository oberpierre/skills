# oberpierre-skills

Instructions for developing this plugin. They sit in `.claude/` because the plugin validator rejects a `CLAUDE.md` at the plugin root, and Claude Code loads them from here as well. The design is in `docs/adr/`, the vocabulary in `GLOSSARY.md`. Work in progress has a plan at `docs/work/<feature>/plan.md`.

- **Gate:** `scripts/gate.sh`, run before every commit by the hook `scripts/gate.sh --install` sets up.
- **Commits:** `arlo-features` as ADR 0003 describes, one behaviour per commit (ADR 0002).
- **Evals:** a skill's behaviour is pinned by eval cases in `evals/<skill>-*`, run only with `evals/run.sh <case>`, which grants the tools the case's first line names (`# allow-tools: …`) and runs it on the model its second line names (`# model: opus`), the one its author runs that skill on (`opus` for planning skills, `sonnet` for `build`). It pins which model a result came from, and asks nothing of users: a skill should work on any model. Run a new case red against the skill before writing the text that should turn it green.
- **Eval budget:** evals spend the user's usage limit, which belongs to feature work. One slice's evals once took nearly a whole five-hour limit. `evals/run.sh` runs one run with no baseline arm, keeps traces, and refuses to start once the last five hours' evals reached `EVAL_BUDGET_USD` (default $3). Never bypass the runner or raise the budget yourself: stop and ask. Per slice:
  - Before running, say what the evals will cost. Stop and ask once a slice's evals pass $1.50.
  - Its own case gets `--runs 3 --baseline` for the red run and `--runs 3` for the last green run. Every other run is one run.
  - When a run fails, read its kept trace and check a changed grader offline against saved replies. Rerun only once the cause is known.
  - Rerun only the cases whose skill text changed, once, one run each, at the end of the slice.
  - One judge split is not a finding. Look into it only when it repeats.
  - A new grader runs once in the eval before it is committed.

## Gotchas

Budget: 40 lines. Each entry is something that cost a round to find out.

- A case is a `case.yaml` with `schema_version: "1.0"`. Its `scaffold_script` must name a file inside the case folder, so each case has a one-line `scaffold.sh` calling `evals/fixtures/scaffold.sh <fixture>`, which runs in the session's working directory.
- Write, Edit and Bash exist in an eval session only when granted with `--allow-tools`. Without the grant, a grader that the agent writes nothing passes because it cannot. Granting Bash needs `bubblewrap` and `socat` installed, or the run refuses to start. A skill's `` !`git …` `` line runs inside the same sandbox, needs `--allow-tools 'Bash(git:*)'`, and is refused when it holds `$(…)`. Run evals in the devcontainer: its `runArgs` let `bwrap` create a namespace and mount `/proc`, and its `TMPDIR=/evaltmp` keeps the eval out of `/tmp`, where its sandbox can write nowhere.
- A `regex` grader on a probe's output also matches the prompt that names the expected text, when the agent echoes the command back. Make the expected text something the command prints but the prompt does not contain.
- A `regex` grader runs in JavaScript, which refuses inline flags such as `(?i)`, and the grader then throws on every run. Put them in the grader's `flags:`. A pattern checked offline in Python can still fail there.
- `--case` takes one pattern. Given twice, only the last runs. `--keep-temp` keeps the traces a grader's verdict needs to be checked against.
- A case with a `history_file` resumes a recorded session, which carries the skill text expanded when it was recorded. The run without the plugin resumes the same text, so such a case measures no lead. The gate fails when the recorded text differs from `SKILL.md`. `python3 evals/refresh-history.py` rewrites it.
- A resume walks `parentUuid` back from the last entry and stops silently at a missing parent. Removing entries from a recording drops everything before the gap, the skill text included, and the agent then works without it. `refresh-history.py` relinks the chain.
- A raw session recording stores the full API request, the user's email address included. Keep only the `user` and `assistant` entries before committing one.
- Resuming a `history_file` writes a session file named after its ID into the case folder. `.gitignore` covers it.
- An `llm` grader with a double negative in its criterion judged the wrong thing. Where the behaviour has a fixed form, a `regex` or `tool_used` grader is checked offline first against saved traces and is then trusted over a judge.
- Claude already looks facts up instead of asking, and maps an idea onto an existing mechanism in a 20-file repository, without being told. Run the case red first, and write a skill line only for what it does not do.
- Asking the model which skills it has is no test of whether a plugin loaded, because `disable-model-invocation: true` hides a user-invoked skill from the model. Type the command in a fresh session and check that the transcript shows it expanded.
- `CLAUDE_CODE_PLUGIN_DIRS` loads a plugin only from the process environment. Set under `env` in a settings file, it does nothing.
- A `context: fork` skill's tool calls reach the trace as subagent calls, and `tool_used` counts them. A `min: 1` grader on a call the fork must make shows that a `max: 0` grader beside it is not passing blind.
- A resumed round that the prompt answers can still open new questions, so a case about the end of a grilling session needs a recording one round deeper. Append the next round from a run's result, not from the session file a resume leaves behind, which keeps only the last run.
