# Closing a plan

`/build close [plan]` and `/build [plan] close` close the feature's plan. `ARGUMENTS.md` says how to recognise `close` and which plan is meant, so apply it before anything below. Running the command is the user's approval of the last slice.

Before anything else, compare the branch you are on with the plan's `**Branch:**` line. When they differ, close nothing, and stop, naming the plan's branch as the one to switch to. Delete no file, commit nothing, push nothing, merge nothing and open no pull request, since the plan is deleted and the branch landed from the branch it names.

Check the config and the plan as `SKILL.md` says under "Before building", leaving out the check of a named slice, and read the default branch from `origin/HEAD`.

## Refuse

Close nothing, and stop, naming every slice that is `todo` or `rework`, with its status, when any slice is. Delete no file, commit nothing, push nothing and open no pull request, since a slice that is still open, or reworked after review, needs its plan.

## Close

This covers an `origin` whose URL host is `github.com`, in HTTPS or SSH form, with `gh` logged in. Do each step yourself with Bash, in this order, and start no coding agent.

1. Read the plan's decision log and judge each decision against three conditions: hard to reverse, would surprise a later reader, and the result of a real trade-off. Suggest the ones that meet all three, each with the reason, and put them to the user as one round through the `grilling` skill, then wait. When none meets them, there is nothing to ask, so go on.
2. Write each decision the user picks as an ADR in `docs/adr/`, numbered after the last one and written the way the others are, and commit them in the configured commit style, with intention `d`.
3. Delete the plan with `git rm`, and commit the deletion as the final commit, in the configured commit style, with intention `d` and the summary `Close the <feature> plan`. Run the gate first.
4. Push the branch with `git push -u origin <branch>`, never a force-push and never the default branch.
5. Open the pull request with `gh pr create --base <default branch> --head <branch>`, titled with the plan's title and with a body of `## Decisions` followed by every decision that was not promoted, as the log wrote it, and then `Closes #<parent>` from the plan's `**Issue:**` line. Leave that line out when the plan has none, and ask nothing about it.

Close neither a slice's issue nor the parent's: the parent closes when the pull request merges. Report the pull request's URL, the decisions promoted, and that the plan stays readable in the branch's history. Review of the pull request's comments then happens outside `build`.
