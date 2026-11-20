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
- `e2e`, when present, is a command like `gate`.
- `tracker` is `markdown` or `github`, `markdown` when the key is missing.

Check the file before you build anything, and stop, naming each problem and the line to add or change, when:

- the file is not valid YAML, or `gate` or `commit_style` is missing;
- `gate` or `e2e` is empty or not a string;
- `commit_style` names neither a preset nor an existing file;
- the style file, or the preset, `extends:` a style that itself extends another;
- `tracker` has any other value;
- `tracker` is `github` and `gh auth status` fails or `gh` is missing.

Never guess a value from the repository. An unknown `build_model` cannot be checked in advance: when the coding agent fails to start on it, stop with that error.

Read the plan's slices table and its `**Branch:**` line. Check the plan before you build anything, and stop, naming each problem and building nothing, when:

- the plan has no `**Branch:**` line or no slices table;
- the table breaks the rules `slice` sets for it: a missing column, a status other than `todo`, `done` or `rework`, an id used twice, or a `Blocked by` that names a slice that is not in the table;
- a `rework` row has an empty note;
- the slice named is not in the table;
- `tracker` is `github` and the table has no `Issue` column, and then also name `/slice` to mirror the slices.

Never repair the plan yourself, since that would change what the user approved. The slice must be `todo`.

Read the default branch from `origin/HEAD`, and when it is not set, ask the user which branch is the default and stop. When you are on the default branch, create the plan's branch from it and switch to it. When you are already on the plan's branch, stay on it. Note the commit you start from with `git rev-parse HEAD`.

## Building

Start one coding agent with the Agent tool, as a general-purpose agent on the `build_model` model, in the foreground (`run_in_background: false`), so its report comes back as the tool's result and your turn does not end while the slice is being built. Hand it pointers only, never pasted content:

```
Read <absolute path of SLICE.md in this skill's folder> and follow it.
Plan: <plan path>
Slice: <slice id>
Start: <start commit>
Gate: <gate command>
Commit style: <absolute path of the style file>
E2E: <the e2e command>
```

Leave out the `E2E` line when `e2e` is not configured.

Wait for its report. Do not build, fix or commit anything yourself.

## Challenging the slice

Once the agent reports the slice built, challenge it once, with both lenses: call the `challenge` skill with `<plan path> <slice id> <start>..HEAD`. Note the commit you are on with `git rev-parse HEAD` first, as `<built>`.

- **Defect findings** go back to the same coding agent, resumed with SendMessage, as the findings' text and the instruction to read `Findings:` in `SLICE.md`. A fact settles a defect, so you do not ask the user about one. It applies them as the commit style says and moves the `done` marking onto the slice's real last commit.
- **Question findings** you keep for the stop.

When history was rewritten, run the gate on every commit of `<start>..HEAD`, for example `git rebase --exec '<gate>' <start>`, not only on the tip. When one is red, run `git rebase --abort`, restore the branch to `<built>` with `git reset --hard <built>` if the abort left it elsewhere, and stop, naming the commit that went red and the kind of failure. Never try to fix it mid-rebase.

## Stopping for review

When the agent reports the slice built, check that the last commit of `git log --oneline <start>..HEAD` is the one that sets the slice's row to `done`. Then tell the user:

- the slice and its behaviour, in one sentence;
- the branch and the commits, oldest first, as `git log --oneline --reverse <start>..HEAD` prints them;
- the acceptance test that pins the behaviour;
- anything the agent could not verify;
- the challenge's question findings, put as a round through the `grilling` skill.

Ask the user to review the commits, and stop.
