# oberpierre-skills

Instructions for developing this plugin. They sit in `.claude/` because the plugin validator rejects a `CLAUDE.md` at the plugin root, and Claude Code loads them from here as well. The design is in `docs/adr/`, the vocabulary in `GLOSSARY.md`. Work in progress has a plan at `docs/work/<feature>/plan.md`.

- **Gate:** `scripts/gate.sh`, run before every commit by the hook `scripts/gate.sh --install` sets up.
- **Commits:** `arlo-features` as ADR 0003 describes, one behaviour per commit (ADR 0002).
- **Evals:** a skill's behaviour is pinned by eval cases in `evals/<skill>-*`, run only with `evals/run.sh <case>`, which grants the tools the case's first line names (`# allow-tools: …`) and runs it on the model its second line names (`# model: opus`), the one its author runs that skill on (`opus` for planning skills, `sonnet` for `build`). It pins which model a result came from, and asks nothing of users: a skill should work on any model.
- **Eval budget:** evals spend the user's usage limit, which belongs to feature work, so no case runs live while a skill is being built (ADR 0010). `evals/run.sh` refuses to start once the last five hours' evals reached `EVAL_BUDGET_USD` (default $3). Never bypass the runner or raise the budget yourself: stop and ask.
  - A slice writes its cases and checks each grader offline, against saved traces where they exist, otherwise against output that should pass it and output that should fail it.
  - A new property is graded on an existing case whose setup already reaches it. Two cases stay separate only when their setups cannot share one run.
  - The whole suite runs once before a release, starting with one case whose trace shows it ran on the models it was routed to. A later release runs `evals/run.sh --changed <previous release tag>`.
  - When a run fails, read its kept trace and check the grader offline before rerunning anything. One judge split is not a finding until it repeats.

## Gotchas

Budget: 40 lines. Each entry is something that cost a round to find out.

- A case is a `case.yaml` with `schema_version: "1.0"`. Its `scaffold_script` must name a file inside the case folder, so each case has a one-line `scaffold.sh` calling `evals/fixtures/scaffold.sh <fixture>`, which runs in the session's working directory.
- Write, Edit and Bash exist in an eval session only when granted with `--allow-tools`. Without the grant, a grader that the agent writes nothing passes because it cannot. Granting Bash needs `bubblewrap` and `socat` installed, or the run refuses to start. A skill's `` !`git …` `` line runs inside the same sandbox, needs `--allow-tools 'Bash(git:*)'`, and is refused when it holds `$(…)`. Run evals in the devcontainer: its `runArgs` let `bwrap` create a namespace and mount `/proc`, and its `TMPDIR=/evaltmp` keeps the eval out of `/tmp`, where its sandbox can write nowhere.
- A `regex` grader on a probe's output also matches the prompt that names the expected text, when the agent echoes the command back. Make the expected text something the command prints but the prompt does not contain.
- A `regex` grader runs in JavaScript, which refuses inline flags such as `(?i)`, and the grader then throws on every run. Put them in the grader's `flags:`. A pattern checked offline in Python can still fail there.
- `--case` takes one pattern. Given twice, only the last runs. `--keep-temp` keeps the traces a grader's verdict needs to be checked against.
- A case with a `history_file` resumes a recorded session, which carries the skill text expanded when it was recorded. The run without the plugin resumes the same text, so such a case measures no lead. The same goes for a recorded Read of a skill's reference file, such as `GITHUB.md`. The gate fails when either differs from the file, and `python3 evals/refresh-history.py` rewrites both, expanding a skill called through the Skill tool with that call's `args`.
- A resume walks `parentUuid` back from the last entry and stops silently at a missing parent. Removing entries from a recording drops everything before the gap, the skill text included, and the agent then works without it. `refresh-history.py` relinks the chain.
- A raw session recording stores the full API request, the user's email address included. Keep only the `user` and `assistant` entries before committing one.
- Resuming a `history_file` writes a session file named after its ID into the case folder. `.gitignore` covers it.
- An `llm` grader with a double negative in its criterion judged the wrong thing. Where the behaviour has a fixed form, a `regex` or `tool_used` grader is checked offline first against saved traces and is then trusted over a judge.
- Claude already looks facts up instead of asking, and maps an idea onto an existing mechanism in a 20-file repository, without being told. Run the case red first, and write a skill line only for what it does not do.
- Asking the model which skills it has is no test of whether a plugin loaded, because `disable-model-invocation: true` hides a user-invoked skill from the model. Type the command in a fresh session and check that the transcript shows it expanded.
- `CLAUDE_CODE_PLUGIN_DIRS` loads a plugin only from the process environment. Set under `env` in a settings file, it does nothing.
- A `context: fork` skill's tool calls reach the trace as subagent calls, and `tool_used` counts them. A `min: 1` grader on a call the fork must make shows that a `max: 0` grader beside it is not passing blind.
- A resumed round that the prompt answers can still open new questions, so a case about the end of a grilling session needs a recording one round deeper. Append the next round from a run's result, not from the session file a resume leaves behind, which keeps only the last run.
- A case cannot set `PATH`, and a stub command in the repository is invisible to the eval's sandbox, which mounts only the workspace. A case with a `bin/` folder has its scaffold copy it to `.eval-bin/`, and `evals/run.sh` puts that relative entry first on the `PATH` the eval inherits. A directory symlink in a case folder fails the case, so `bin/` is a real folder holding file symlinks.
- An `llm` grader takes no `target`, and with `focus: files` its evidence lists the workspace's file names without their contents, so a judge of a file's contents fails blind. Grade a file with `regex` graders, checked offline against saved files.
