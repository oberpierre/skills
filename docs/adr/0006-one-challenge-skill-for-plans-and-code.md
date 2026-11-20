# One challenge skill attacks plans and code

`challenge` reviews an artifact adversarially, from a context that never saw the conversation that produced it. It assumes the artifact is wrong somewhere, looks for where, and never edits. It has two subjects and a reference file for each:

- **`PLAN.md`**, for a plan: is it building a second mechanism beside an existing one, does it infer what it could be told, what does it do with malformed configuration and malformed data, can its proof pass while the defect survives, what falls between its slices, what contradicts an ADR or the code, and which decisions are expensive to undo.
- **`CODE.md`**, for a diff, through two lenses. The **diff lens** sees only the diff and judges it against the repository's standards and a baseline of code smells. The **plan lens** sees the diff, the slice and its decisions, and names for each acceptance criterion the assertion that pins it.

`grill` calls it on the plan at the end of every session, and its findings become the last round of questions to the user. `build` calls it on each slice before stopping, and its findings become fixups. The user can call it directly on either.

It runs with `context: fork`, so a fresh context does not depend on each caller remembering to dispatch one. A forked context receives the arguments it is called with and none of the conversation, so a caller passes pointers and never pasted content. On Claude Code 2.1.325, a forked context sees nothing of the calling turn, whether the model calls the skill or the user types it, and it has the `Agent` tool, so a lens that needs a context of its own dispatches a subagent.

## Why

A plan review and a code review share their stance (fresh context, presumption of a defect, no edits) and differ in what they attack. One skill with two reference files keeps the stance in one place and loads only the attack lines the subject needs.

Reviewing in a context that saw the conversation reproduces the conversation's blind spots, which is the failure the review exists to catch. The two lenses of a code challenge see different evidence for the same reason, since lenses that see the same thing miss the same things.

Naming the assertion per criterion is what makes a test too weak for its slice visible, because a criterion with no assertion, or with one that cannot fail, is then a finding rather than an impression.
