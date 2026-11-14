# oberpierre-skills

Agent skills for building software in small, reviewed steps. You make every decision about the shape of the work, and the agent finds the facts, builds one behaviour at a time and stops to ask whenever it meets a question nobody has answered. What you review is a short series of commits, each changing one behaviour behind a green gate.

Built for solo projects, and usable in any repository: the build, test and tracker details of a project live in its own `.agents/config.yml`, never in the skills.

> **Status:** in development. The design is recorded in [docs/adr/](docs/adr/), and the skills are being written one at a time.

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
| `challenge` | agent or you | Attacks a plan or a diff from a context that never saw it being made |
| `tdd` | agent or you | Red, then green, one behaviour at a time, tested at agreed seams |
| `diagnosing-bugs` | agent or you | Builds a loop that fails on the bug before theorising about it |
| `prototype` | agent or you | Throwaway code that answers one design question |
| `pr` | agent or you | The shape of a pull request body |

## Install

Not released yet. Once it is:

```bash
claude plugin marketplace add oberpierre/skills
claude plugin install oberpierre-skills@oberpierre
```

Run `/setup` once in each repository. If a skill name clashes with another, `/oberpierre-skills:<skill>` reaches this one.

## Developing the skills

After cloning, run `scripts/gate.sh --install` once, so the gate runs before every commit. Git does not version hooks, which is why the step exists. The gate needs the `claude` CLI, either on your `PATH` or inside the VS Code extension.

Point a project at your working copy by adding this to its `.claude/settings.local.json`:

```json
{ "env": { "CLAUDE_CODE_PLUGIN_DIRS": "/path/to/oberpierre-skills" } }
```

The working copy takes precedence over an installed version from the next session on.

## Credits

Built on Matt Pocock's [mattpocock/skills](https://github.com/mattpocock/skills). See [CREDITS.md](CREDITS.md) for every source. MIT licensed, see [LICENSE](LICENSE).
