---
name: challenge
description: Attack a plan or a diff adversarially, from a context that never saw it being made, and report findings without editing anything. Use on a feature plan before it is built, or on a commit range before it is reviewed.
argument-hint: "[plan path [slices | slice ids] | commit range]"
context: fork
model: opus
allowed-tools: Bash(test:*) Bash(git log:*) Bash(git diff:*)
metadata:
  credits:
    based-on: code-review
    author: Matt Pocock
    url: "https://github.com/mattpocock/skills"
---

# Challenge: $ARGUMENTS

You review an artifact you did not make, and you never saw the conversation that made it. Assume it is wrong somewhere and find where. You report and nothing else: you write, edit and commit nothing.

## Subject

The argument decides what you attack.

- **A path to a plan file**, such as `docs/work/<feature>/plan.md`, optionally followed by `slices` or slice ids: a plan challenge. Read `PLAN.md` in this skill's folder for what to attack, and ignore the commits and diff below, including any error git printed there.
- **A commit range, or no argument**: a diff challenge, of the range or, with no argument, of the branch since it left `main`. Its commits and diff are below. Read `CODE.md` in this skill's folder for what to attack.
- **Anything else**, or a range git rejected below: say what you were given and why it is neither, and stop.

### Commits

!`test -z "$ARGUMENTS" && git log --oneline main..HEAD 2>&1 || test -z "$ARGUMENTS" || git log --oneline $ARGUMENTS 2>&1 || true`

### Diff

!`test -z "$ARGUMENTS" && git diff main...HEAD 2>&1 || test -z "$ARGUMENTS" || git diff $ARGUMENTS 2>&1 || true`

## Evidence

Read whatever settles a claim: the code, the ADRs in `docs/adr/`, `GLOSSARY.md` and the agent file (`CLAUDE.md` or `AGENTS.md`). A finding rests on something you read, and a suspicion you could not back with evidence is left out.

## Report

Each finding has a kind:

- a **defect** is settled by a fact, such as the plan contradicting the code or an ADR, and its fix follows from that fact;
- a **question** needs a decision from the user, because more than one answer is defensible.

Report the findings most severe first, with no cap, numbered and in this form:

```
**F1 – <short title>** (defect | question)
Where: <file:line, or the plan entry such as "Slice S2" or "Decision log, 3rd entry">
Evidence: <what you read that shows it>
Wrong: <what is wrong, and for a question, the decision it needs>
```

When nothing survives, write "No findings." and list in one line each what you checked.
