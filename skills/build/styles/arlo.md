# Arlo's Commit Notation

A condensed version of [Arlo's Commit Notation](https://github.com/RefactoringCombos/ArlosCommitNotation), written for an agent to apply.

A subject is `<risk> <intention> <summary>`: a risk marker, a space, an intention letter, a space, and a summary in the imperative or present tense, such as `^ F Orders can be cancelled before they ship`.

## Risk

The risk marker says how well the change is known to be safe.

- `.` Provably safe: nothing it changes can alter behaviour, such as a documentation edit or a refactoring an automated tool made.
- `^` Validated: tests show the behaviour works, and the gate passed.
- `!` Risky: something could not be verified.
- `@` Probably broken, or no attempt was made to verify it.

The agent that ran the gate sets the marker, and it writes `!` whenever something could not be verified.

## Intention

The intention letter says what the change is for. A capital letter marks a change a user of the software can see, and a lowercase letter one only developers can see.

- `F` / `f` a feature, new or changed behaviour.
- `B` / `b` a bug fix.
- `R` / `r` a refactoring, with no change to behaviour.
- `D` / `d` documentation.
- `E` / `e` the environment, such as the build, dependencies or tooling.
- `t` tests only.

## Corrections

Every correction is a commit of its own, with its own subject. History is never rewritten to hide one.
