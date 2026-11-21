---
name: build
description: Build one slice of a feature's plan, or every remaining slice, test-first and one commit per behaviour behind the gate, challenge the result, then stop for your review.
argument-hint: "[slice id [comment] or plan]"
disable-model-invocation: true
---

# Build: $ARGUMENTS

Build the slice the argument names, such as `S1`, from the feature's plan. When words follow the slice id, they are a review comment, and you build nothing: see "When the slice is a rework, or there is a review comment". Use the only plan under `docs/work/`, and when there are several or none, ask which plan to build and stop. When the argument is a plan, a path or a folder name under `docs/work/`, read `FEATURE.md` in this skill's folder and follow it, which builds every remaining slice with the sections below.

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

Never repair the plan yourself, since that would change what the user approved. A slice named by id must be `todo` or `rework`, and a plan builds every slice that is either.

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

Leave out the `E2E` line when `e2e` is not configured. Wait for its report, and build, fix and commit nothing yourself.

## When the slice is a rework, or there is a review comment

Instead of "Building" and "Challenging the slice", read `REWORK.md` in this skill's folder for a `rework` slice, which carries its note out in place, and `COMMENT.md` for a review comment, which refuses a slice that cannot take one and has the correction made as the commit style says. Each challenges or stops for review as it says.

## Challenging the slice

Once the agent reports the slice built, challenge it once, with both lenses: call the Skill tool with `challenge`, with `<plan path> <slice id> <start>..HEAD` as its argument. Note the commit you are on with `git rev-parse HEAD` first, as `<built>`.

- **Defect findings** go back to the same coding agent, resumed with SendMessage, as the findings' text and the instruction to read `Findings:` in `SLICE.md`. A fact settles a defect, so you do not ask the user about one. It applies them as the commit style says and moves the `done` marking onto the slice's real last commit.
- **Question findings** you keep for the stop.

When the commit style makes corrections fixups, squash them with `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash --exec '<gate>' <start>`, which runs the gate on every rewritten commit and not only on the tip. When one is red, run `git rebase --abort`, restore the branch to `<built>` with `git reset --hard <built>` if the abort left it elsewhere, and stop, naming the commit that went red and the kind of failure. Never try to fix it mid-rebase.

## When the agent returns a question

When the agent's report starts with `Question:`, it needs a choice the plan does not make, and it has committed nothing for that behaviour. Do not answer it yourself. Put the question to the user as a round, calling the Skill tool with `grilling`, with the agent's recommendation as the recommended answer. Write the answer into the plan's decision log, leaving the edit uncommitted, and resume the same agent with SendMessage as `Answer:` followed by the question and the answer, with the instruction to read `Answer:` in `SLICE.md`. When the answer changes a slice's behaviour, stop and name `/slice` instead.

Start the message that holds a round, for a question or for a wrong premise below, with a line that starts `For retro:` and names the question the planning missed, ahead of `Q1`, because the round ends your turn and nothing you write after it is read as your report.

## When the gate stays red

When the agent reports that the gate stayed red, it has left the red behaviour's attempt uncommitted and the behaviours that went green earlier committed. Fix nothing yourself. Tell the user the failing command, the kind of failure it reports, written as the bold phrase of the matching item below, and the commits already in `<start>..HEAD`, as `git log --oneline --reverse <start>..HEAD` prints them, or that there are none:

- **A defect in its own code:** offer to debug it together, and wait. When the user accepts, resume the same agent with SendMessage and debug with the user.
- **A broken environment:** say what is missing, and stop.
- **A wrong premise:** put the contradiction to the user as a round, calling the Skill tool with `grilling`. Write the answer into the plan's decision log, leaving the edit uncommitted, and resume the same agent with SendMessage as `Premise answer:` followed by the question and the answer, with the instruction to read `Premise answer:` in `SLICE.md`. When the answer changes a slice's behaviour, stop and name `/slice` instead.

## Stopping for review

When the agent reports the slice built, check that the last commit of `git log --oneline <start>..HEAD` is the one that sets the slice's row to `done`. Then tell the user:

- the slice and its behaviour, in one sentence;
- the branch and the commits, oldest first, as `git log --oneline --reverse <start>..HEAD` prints them;
- the acceptance test that pins the behaviour;
- anything the agent could not verify;
- the queued questions, oldest first, put as one round, calling the Skill tool with `grilling`: every question you must put to the user, whether a challenge's finding, an agent's question or a wrong premise, is appended to the queue as it arises, and any round puts the whole queue.

Ask the user to review the commits, and stop. For a plan, `FEATURE.md` says what the stop reports instead.
