# Closing a plan

`/build close [plan]` and `/build [plan] close` close the feature's plan. `ARGUMENTS.md` says how to recognise `close` and which plan is meant, so apply it before anything below. Running the command is the user's approval of the last slice.

Check the config and the plan as `SKILL.md` says under "Before building", leaving out the check of a named slice, and read the default branch from `origin/HEAD`.

## Refuse

Close nothing, and stop, naming every slice that is `todo` or `rework`, with its status, when any slice is. Delete no file, commit nothing, push nothing and open no pull request, since a slice that is still open, or reworked after review, needs its plan.
