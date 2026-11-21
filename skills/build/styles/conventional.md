# Conventional Commits

A condensed version of [Conventional Commits 1.0](https://www.conventionalcommits.org/en/v1.0.0/), written for an agent to apply.

## Format

A subject is `<type>(<scope>)?: <summary>`, with the scope optional, in the imperative and in lower case after the colon, such as `feat(notify): link a shipped order's tracking page`. A breaking change adds `!` before the colon.

## Types

- `feat` new or changed behaviour a user can see.
- `fix` a bug fix.
- `refactor` a change that alters no behaviour.
- `docs` documentation only.
- `test` tests only.
- `build` the build, dependencies or tooling.
- `chore` anything else that touches no behaviour.

## Corrections

A correction of a review finding becomes a fixup of the commit it corrects, made with `git commit --fixup=<commit>`, and is squashed into it before the user reviews the slice. A correction that records a discovery stays a commit of its own.

## The gate

The message carries no marker for the gate. The gate still passes before every commit, whatever the style.
