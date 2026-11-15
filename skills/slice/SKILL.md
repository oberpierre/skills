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

## Slices

A slice is one behaviour built end to end and pinned by an acceptance test, small enough to review as a few commits. Cut along behaviours a user or caller can observe, never along layers, so no slice is only a model, only a schema or only wiring. Order them so each slice can be built once the slices it is blocked by are done, and give every decision in the log a slice that carries it out or say why none does.

Each slice is one row of this table:

```
| Slice | Behaviour | Acceptance test | Blocked by | Status | Base | Head | Note |
|---|---|---|---|---|---|---|---|
| S1 | <the observable behaviour, in one sentence> | `<test name>`, through <the seam it is tested through> | none | todo | | | |
```

- **Slice** is the id, `S1`, `S2`… in build order.
- **Acceptance test** names the test and the seam, the public boundary it observes the behaviour through. Its code is written when the slice is built.
- **Blocked by** lists slice ids, or `none`.
- **Status** is `todo`, `done` or `rework`. A new slice is `todo`, and Base, Head and Note stay empty.

## Proposing

Show the proposed table, with a line under it for anything a reader of the table would ask about, such as why two behaviours share a slice. Then ask the user to approve it or say what to change, and stop. Write nothing in this step.

## Writing

Once the user approves, write the table into the plan under `## Slices`, placed before `## Decision log`, and leave the rest of the plan as it was.
