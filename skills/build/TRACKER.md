# Closing slice issues

Only when `tracker` is `github`. `build` closes each issue once, at the stop `SKILL.md` describes under "Stopping for review", for a slice and for a rework alike, and nothing else closes one. Inside `/build <plan>` the stop is the final one: every issue closes there, a rework's removed rows included, once the whole-branch challenge and its gate rerun are green, and none closes as its slice reaches `done` within the run. A single-slice `/build S<n>` closes at its own stop. The plan stays the source of truth and a slice's issue only mirrors its row, so close an issue only after the table says so, and find it only by the number in the slice's `Issue` cell, never by searching GitHub. Run each command through Bash, one call per command.

## A slice that is done

Once the stop's check shows the last commit of the slice's range sets its row to `done`, which is after the challenge's corrections are in, close its issue:

```
gh issue close <n> --reason completed
```

This holds for a rework that returns a row to `done` too, since `/slice` reopened that issue when it marked the row, and for the surviving row of a squash. Close nothing while the gate is red or the run stopped early, because the slice is not done then.

## A row the rework removes

A squash or a revert removes rows from the table, and their issues will never be built. Close each as not planned, with a comment that says why:

```
gh issue close <n> --reason "not planned" --comment "<comment>"
```

- For a squash, the comment names the slice that absorbed it: `Absorbed by S<m>`, using the surviving row's id.
- For a revert, the comment is `Reverted by rework of S<n>`, naming the slice whose rework reverted it.

Read the removed row's issue number from the table before the rework rewrites it, since the row is gone afterwards.
