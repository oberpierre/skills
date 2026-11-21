# Carrying out a rework

A `rework` slice is carried out from its note, in place, and builds nothing new unless the note says to rebuild. Check the config and the plan as `SKILL.md` says under "Before building", then do the following.

## Read the shape

The note names one of three shapes:

- **squash**: the commits of the slices it names are folded into the lowest-numbered of them, which survives with the behaviour of all;
- **revert**: the slice's behaviour is removed;
- **rebuild**: the slice keeps its row and its commits are replaced by new ones built from the note.

When the note names none of them, stop, build nothing and name `/slice`, so that the note gets fixed. Refuse a slice whose commits are already in `origin/<default branch>` as `COMMENT.md` says under "Refuse" for a merged one.

Call the row that survives the **subject**: the slice itself, or for a squash named by an absorbed row, such as the note "Squash into S1" on S2, the lowest-numbered row the note names. Carry a squash out on the subject and challenge it as the subject.

## Carry it out

Find the range of every slice the note involves as `COMMENT.md` says under "Find the slice's commits", and take `<base>` from the oldest and `<head>` from the newest. Note `<pre>` with `git rev-parse HEAD`. With `tracker: github`, note the issue numbers of the rows the rework removes first, as `TRACKER.md` says, since the stop closes the issues.

Start the coding agent as `SKILL.md` describes under "Building", with `Start: <base>` in place of the start commit and the extra lines `Rework: <the note>` and `Range: <base>..<head>` and the instruction to read `Rework:` in `SLICE.md`. How the commits change follows the commit style, as `COMMENT.md` says under "Correct":

- when the style makes corrections fixups, such as `arlo-features`, a revert drops the slice's commits by interactive rebase, and a squash and a rebuild rewrite them there;
- when the style makes each correction a commit of its own, such as `arlo`, history is never rewritten: a revert adds `git revert` commits, and a squash or a rebuild adds commits that do the same work.

The agent runs the gate on every rewritten commit, and returns the table's final state in the rework's last commit. When it reports a red commit, run `git rebase --abort` if a rebase is open, run `git reset --hard <pre>`, and stop, naming the commit that went red and the kind of failure.

## Challenge and stop

Once the history is rewritten, `<start>` names a commit that is no longer in it, so `<base>` stands wherever "Challenging the slice" and `SLICE.md` say `<start>`, the gate rerun on every commit included.

Challenge the rework once as `SKILL.md` says under "Challenging the slice", with `<plan path> <subject id> <base>..HEAD` and `<pre>` as `<built>`. Then check, for a squash or a rebuild, that the last commit of `git log --oneline <base>..HEAD` sets the subject's row to `done` with its Note empty, that no absorbed row is left in the table and that no subject line starts with `fixup!` or `squash!`. After a revert there is no `done` to check: the challenge still runs with the slice id on `<base>..HEAD`, and you check that the behaviour is gone and the row removed. Report as `SKILL.md` says under "Stopping for review", naming the shape and the rows that went, and ask the user to review the commits.

Inside `/build <plan>`, a rework has no stop of its own: its questions join the queue, and the run skips a row that a squash or a revert removed.
