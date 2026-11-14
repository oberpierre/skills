# How a skill is written

**Invocation.** A skill that has side effects or needs the user is user-invoked, with `disable-model-invocation: true`, and its description is written for a person browsing the `/` menu. A skill that holds a discipline or reference worth applying unasked is model-invoked, and its description says when to use it. A skill can call only model-invoked skills, so anything another skill composes is model-invoked.

User-invoked: `setup`, `grill`, `slice`, `build`, `retro`, `wait-what`. Model-invoked: `challenge`, `tdd`, `pr`, `prototype`, `diagnosing-bugs`.

**Composition.** A skill calls another with an explicit instruction, "Call the Skill tool with `tdd`", one skill per call. It never links into another skill's folder, since material a skill owns is reached by calling that skill. A called skill shares the caller's context, so a step that needs a fresh one dispatches a subagent instead, handing it pointers rather than pasted content.

**Size.** A `SKILL.md` stays under about 100 lines, and detail goes into sibling files that the skill reads when it needs them. Repository specifics never appear in a skill: they come from `.agents/config.yml`.

**No history.** A skill states a rule once and never the incident that produced it. The incident goes into an ADR in this repository.

**Claude Code mechanisms.** `argument-hint` shows a skill's arguments in the `/` menu, `$ARGUMENTS` carries what the user typed, a `` !`command` `` line injects live state when the skill loads, and `model` routes reasoning-heavy skills to a stronger model.

## Why

The split by invocation keeps a skill that commits or pushes from firing because a conversation resembled its description. An explicit instruction to call the Skill tool is followed more reliably than a skill name left in prose.

Instructions that carry their incidents grow with every incident and get skimmed as a result. A rule stated once and justified elsewhere stays short enough to be read in full on every run.
