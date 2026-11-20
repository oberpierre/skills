---
name: build
description: Build an approved slice from a feature's plan, test-first and one commit per behaviour behind the gate, then stop for your review.
argument-hint: "[slice id]"
disable-model-invocation: true
---

# Build: $ARGUMENTS

Build the slice the argument names, such as `S1`, from the feature's plan. Use the only plan under `docs/work/`, and when there are several or none, ask which plan to build and stop.

You do not write the slice's code yourself. A coding agent builds it, and you hold its report and nothing else, so you stay small enough to run a whole feature.

## Before building

Read `.agents/config.yml`:

- `gate` is the command that checks the whole repository. A commit is made only when it passes.
- `commit_style` names a preset, `arlo` or `arlo-features`, which is the file of that name in the `styles` folder beside this skill, or a path to a style file in the repository.
- `build_model` is the model the coding agent runs on, `sonnet` when the key is missing.

Read the plan's slices table and its `**Branch:**` line. The slice must be `todo`.

Read the default branch from `origin/HEAD`. When you are on the default branch, create the plan's branch from it and switch to it. When you are already on the plan's branch, stay on it. Note the commit you start from with `git rev-parse HEAD`.

## Building

Start one coding agent with the Agent tool, as a general-purpose agent on the `build_model` model. Hand it pointers only, never pasted content:

```
Read <absolute path of SLICE.md in this skill's folder> and follow it.
Plan: <plan path>
Slice: <slice id>
Start: <start commit>
Gate: <gate command>
Commit style: <absolute path of the style file>
```

Wait for its report. Do not build, fix or commit anything yourself.

## Stopping for review

When the agent reports the slice built, check that the slice's row now says `done` and that `git log --oneline <start>..HEAD` lists its commits. Then tell the user:

- the slice and its behaviour, in one sentence;
- the branch and the commits, oldest first, as `git log --oneline --reverse <start>..HEAD` prints them;
- the acceptance test that pins the behaviour;
- anything the agent could not verify.

Ask the user to review the commits, and stop.
