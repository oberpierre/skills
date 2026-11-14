# Distribution

The repository is `oberpierre/skills`, public and under the MIT license. It is a Claude Code plugin named `oberpierre-skills`, and `.claude-plugin/marketplace.json` makes the repository its own marketplace, named `oberpierre`. A user installs it with `claude plugin marketplace add oberpierre/skills` and `claude plugin install oberpierre-skills@oberpierre`. An installed copy updates when the `version` in `.claude-plugin/plugin.json` changes. On a name clash with another skill, `/oberpierre-skills:<skill>` reaches this one.

For developing the skills, the environment variable `CLAUDE_CODE_PLUGIN_DIRS` names a working copy. It has to be in the environment Claude Code starts with: a shell profile for the CLI, and the editor extension's `claudeCode.environmentVariables` setting for the extension. A plugin loaded this way takes precedence over the installed one, so edits take effect from the next session with nothing to uninstall.

The repository started fresh rather than as a fork of `mattpocock/skills`. A skill that is substantially Matt Pocock's keeps his name and credits him in its frontmatter `metadata`: `tdd`, `pr`, `prototype`, `wait-what`, `diagnosing-bugs`. A skill that diverges has its own name and credits its inspiration the same way. `CREDITS.md` lists every source.

## Why

A managed install keeps every project on the current version without copying files around, and a public repository installs without credentials.

A fork would have brought dozens of skills to delete, release machinery built for another project's scale, and a link that suggests upstream changes are tracked when they are not.

Keeping Matt's names where the skill is his keeps his documentation applicable and makes the debt plain. The plugin name carries the owner's name because a generic name such as `skills` could be claimed by any other plugin.

## History

**2026-11-15.** Dev mode was first set under `env` in the consuming project's `.claude/settings.local.json`, on the strength of one line in the CLI's own text. Tested in fresh sessions, that route never loaded the plugin, and `/grill` arrived as plain text, whereas the same variable in the process environment, and `--plugin-dir`, both loaded it.
