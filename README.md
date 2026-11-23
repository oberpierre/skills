# oberpierre-skills

Agent skills for building software in small, reviewed steps. You make every decision about the shape of the work, and the agent finds the facts, builds one behaviour at a time and stops to ask whenever it meets a question nobody has answered. What you review is a short series of commits, each changing one behaviour behind a green gate.

Built for solo projects, and usable in any repository: the build, test and tracker details of a project live in its own `.agents/config.yml`, never in the skills.

> **Status:** in development. `grill`, `challenge`, `slice` and `build` are usable, and the other skills are being written one at a time. The design is recorded in [docs/adr/](docs/adr/).

## How it works

```
/setup     once per repository: gate command, tracker, commit style
/grill     you decide the shape, in rounds of questions, ending with a challenge of the plan
/slice     the plan as ordered vertical slices, each with its acceptance test
/build     one slice, or the whole feature, test-first, one commit per behaviour
/retro     what this feature taught, turned into checks, standards or changes to the skills
```

You take part in grilling, in approving the slices and in reviewing each slice's commits. Everything between those runs without you.

## Skills

| Skill | Invoked by | What it does |
|---|---|---|
| `setup` | you | Writes `.agents/config.yml` and points the agent file at it |
| `grill` | you | Interviews you until every decision is made, and records them as you go |
| `slice` | you | Turns the decisions into a plan of vertical slices |
| `build` | you | Builds slices serially, each in a fresh subagent, challenged before it stops |
| `retro` | you | Proposes improvements to the environment after a feature |
| `wait-what` | you | Re-explains a message that did not land |
| `grilling` | agent or you | Asks in numbered rounds, a recommended answer each, until a subject's decisions are made |
| `challenge` | agent or you | Attacks a plan or a diff from a context that never saw it being made |
| `tdd` | agent or you | Red, then green, one behaviour at a time, tested at agreed seams |
| `diagnosing-bugs` | agent or you | Builds a loop that fails on the bug before theorising about it |
| `prototype` | agent or you | Throwaway code that answers one design question |
| `pr` | agent or you | The shape of a pull request body |

## Install

```bash
claude plugin marketplace add oberpierre/skills
claude plugin install oberpierre-skills@oberpierre
```

Run `/setup` once in each repository. If a skill name clashes with another, `/oberpierre-skills:<skill>` reaches this one.

## Developing the skills

After cloning, run `scripts/gate.sh --install` once, so the gate runs before every commit. Git does not version hooks, which is why the step exists. The gate needs the `claude` CLI, either on your `PATH` or inside the VS Code extension.

An eval case that resumes a recorded conversation replays the skill text from when it was recorded. After editing a `SKILL.md`, run `python3 evals/refresh-history.py`, or the gate stops the commit.

To try your working copy in another project, start Claude Code with the environment variable `CLAUDE_CODE_PLUGIN_DIRS` naming it. Setting it in the `env` block of a project's `.claude/settings.local.json` does not load the plugin.

- **Terminal:** add `export CLAUDE_CODE_PLUGIN_DIRS=/path/to/oberpierre-skills` to your shell profile, or start one session with `claude --plugin-dir /path/to/oberpierre-skills`.
- **VS Code extension:** add this to your user settings, or in a dev container to its remote settings (**Preferences: Open Remote Settings (JSON)**), then reload the window:

  ```json
  "claudeCode.environmentVariables": [
    { "name": "CLAUDE_CODE_PLUGIN_DIRS", "value": "/path/to/oberpierre-skills" }
  ]
  ```

The working copy takes precedence over an installed version from the next session on.

## Credits

Built on Matt Pocock's [mattpocock/skills](https://github.com/mattpocock/skills). See [CREDITS.md](CREDITS.md) for every source. MIT licensed, see [LICENSE](LICENSE).
