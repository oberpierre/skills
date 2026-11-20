---
name: slice
description: Turn a feature's decisions into a plan of ordered vertical slices, each with its acceptance test, for you to approve before anything is built.
argument-hint: "[plan] [request]"
disable-model-invocation: true
metadata:
  credits:
    based-on: to-tickets
    author: Matt Pocock
    url: "https://github.com/mattpocock/skills"
---

# Slice: $ARGUMENTS

Turn the decisions in a feature's plan into slices. The argument's first word is the plan only when it is a path or names a plan under `docs/work/`, and the rest is a request, such as `squash S1 and S2`. With no plan named, use the only plan under `docs/work/`, and when there are several or none, ask which plan to slice and stop, even if the request seems to point at one. Read the plan's decision log, and read the code wherever a decision names something that already exists.

You change no code, and you write nothing until the user approves the slices.

Read `.agents/config.yml` if it exists. Its `tracker` key is `markdown` or `github`, and a missing file or key means `markdown`. When the file is not valid YAML, or `tracker` is any other value, report it and stop, proposing nothing. With `github`, run `gh auth status` first, and when `gh` is missing or not logged in, say so and stop, proposing nothing, rather than carrying on with the Markdown plan alone.

## Slices

A slice is one behaviour built end to end and pinned by an acceptance test, small enough to review as a few commits. Cut along behaviours a user or caller can observe, never along layers, so no slice is only a model, only a schema or only wiring. Order them so each slice can be built once the slices it is blocked by are done, and give every decision in the log a slice that carries it out or say why none does.

Each slice is one row of this table:

```
| Slice | Behaviour | Acceptance test | Blocked by | Status | Note |
|---|---|---|---|---|---|
| S1 | <the observable behaviour, in one sentence> | `<test name>`, through <the seam it is tested through> | none | todo | |
```

- **Slice** is the id, `S1`, `S2`… in build order.
- **Acceptance test** names the test and the seam, the public boundary it observes the behaviour through. Its code is written when the slice is built.
- **Blocked by** lists slice ids, or `none`.
- **Status** is `todo`, `done` or `rework`. A new slice is `todo`, and its Note stays empty.

When the plan already has a slices table that lacks one of these columns, has another status, uses an id twice or is blocked by anything but slice ids, report each problem and stop, proposing nothing. Fixing it yourself could change what the user approved.

## Proposing

Show the proposed table, with a line under it for anything a reader of the table would ask about, such as why two behaviours share a slice. When the plan has no `**Branch:**` line, suggest a branch name in one of those lines, `<prefix>/<slug>`, with `<slug>` the plan's folder name and `<prefix>` the one of `feature`, `bugfix` and `improvement` that fits what the decisions describe. Then ask the user to approve it or say what to change, and stop. Write nothing in this step.

Most plans raise no questions, and then the table goes out alone. Ask a question only when the table cannot be cut without it: when a different answer would change a slice's behaviour, the seam its test goes through, such as a boundary the code does not have yet, or the order of the slices. Do not ask how a slice is built, such as a signature, where a value is read from, where an error is caught or how an outside service is faked in a test, since that is decided when the slice is built. Do not ask what the log or the code already answers. A needless question costs the user a round.

When a question passes that bar, first call the Skill tool with `grilling`, with those decisions as its argument, and then reply with the table, its lines and the round under them, all in one reply. Once nothing is open, propose the table again with the decisions listed under it.

## Writing

Once the user approves, write the table into the plan under `## Slices`, placed before `## Decision log`. Add each answered question to the decision log as a decision with its reason. Write the approved branch name, as the user left it, on a `` **Branch:** `<name>` `` line under the plan's title, and leave the rest of the plan as it was. Create or switch no branch: the branch is made where the first change is built.

Then challenge the slicing once. Call the Skill tool with `challenge`, with the plan's path followed by `slices` when the table was written for the first time, or by the ids of the slices this run changed, such as `docs/work/sms/plan.md S2 S3`. The decisions were challenged when they were made. If it finds nothing, say so and stop. Otherwise call the Skill tool with `grilling`, with the findings as its argument, and put every finding to the user as one round, each title starting with `Challenge:`. Phrase a defect as "Fix as stated?", and where you disagree with a finding, recommend dismissing it and say why. Record the answers in the decision log, and change the table where an answer changes a slice.

## Rework

When the request names a `done` slice, such as `squash S1 and S2`, first check that its commits are still on the unmerged feature branch: find the commit in the plan's history that set its row to `done`, and see whether it is in the history of the default branch, read from `origin/HEAD`. When `origin/HEAD` is not set, ask the user which branch is the default and stop, since a failed check says nothing about whether the slice is merged. If the commit is in that history, say that the slice is merged and a new plan is needed, since rewriting merged commits rewrites shared history, and stop, marking nothing. Otherwise propose the change as a round before touching the plan: call the Skill tool with `grilling`, with the change as its argument, and reply with the round, recommending the shape you think best. Leave `done` slices alone otherwise. Once the user approves, mark each affected slice `rework` with a one-line note of what is to be done, change nothing else of the built slices, and end by naming the `/build` command to run. Run no git command that rewrites history: `build` carries the rework out.

## Mirroring

With `tracker: github`, mirror the slices to GitHub Issues once the challenge's answers are recorded, or at once when the request only asks to mirror an approved table. Read `GITHUB.md` in this skill's folder for the commands, and follow it. The plan stays the source of truth, so never change a slice to match an issue.
