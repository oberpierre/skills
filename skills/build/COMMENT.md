# Folding a review comment

`/build S1 <comment>` corrects a slice that was built and builds nothing new. Check the config and the plan as `SKILL.md` says under "Before building", then do the following.

## Refuse

Refuse, naming the reason, building and committing nothing and starting no agent, when the slice is:

- `todo`: say to run `/build S<n>` first, naming the slice;
- `rework`: say to drop the comment, since a rework is carried out from its note;
- merged: its head, found below, is an ancestor of `origin/<default branch>`.

## Find the slice's commits

Slices are not always built in number order, so use the plan's history. List `git log --format=%H -- <plan path>` newest first, and a commit turns row `S1` to `done` when `git show <commit> -- <plan path>` removes the row with another status and adds it with `done`, or adds it already `done`, as the commit that first adds the plan does for a one-commit slice. An edit to another cell of the row, such as a new `Issue` column, does not count.

- `<head>` is the first commit in that list that turns the slice's row to `done`.
- `<base>` is the first commit older than `<head>` that turns any other row to `done`, or `git merge-base HEAD origin/<default branch>` when there is none.

## Correct

Start the coding agent as `SKILL.md` describes under "Building", with the extra lines `Comment: <the comment>` and `Range: <base>..<head>` and the instruction to read `Comment:` in `SLICE.md`. It makes the corrections as the commit style says for a correction of a review finding. Note `<pre>` with `git rev-parse HEAD` once it reports.

When the style makes the corrections fixups, squash them with `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash --exec '<gate>' <base>`. That rewrites the slice's commits and every commit built after them, running the gate on each. When a commit goes red, or the rebase stops on a conflict, run `git rebase --abort`, run `git reset --hard <pre>` so the agent's fixups stay, and stop, naming the commit that went red or conflicted and the kind of failure. Never try to fix it mid-rebase.

When the style makes each correction a commit of its own, rewrite nothing, since the gate has already run on each of them.

## Stop for review

Check that `git log --oneline --reverse <base>..HEAD` shows no `fixup!` or `squash!` subject and that the slice's row is still `done`. Then report:

- the slice and the comment, in one sentence;
- the commits of `<base>..HEAD` that the comment changed, and the later slices' commits that were rewritten on top of them, each marked as such, oldest first;
- anything the agent could not verify.

Ask the user to review the commits, and stop.
