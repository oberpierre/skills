# Building the whole feature

For a plan argument, `SKILL.md` runs once per slice and this file changes what happens around those runs.

## The slices

Build every slice that is `todo` or `rework`, one after another in the order the table gives. Each has its own coding agent, `<start>` and slice challenge, and a `rework` slice is carried out as `REWORK.md` says, without its own stop, so its questions join the queue below. Skip a row that an earlier squash or revert removed.

Skip a slice whose `Blocked by` names a slice still unfinished, and return to it after the others. When a whole pass over the remaining slices builds none, stop and name the slices that cannot be built and the blockers each waits for.

## Questions

A question the coding agent returns and a red gate are handled at once, as `SKILL.md` says in "When the agent returns a question" and "When the gate stays red": the user is asked, the answer logged and the same agent resumed. A challenge's question findings wait for the stop.

Every question you must put to the user is appended to a queue as it arises, whether a challenge's finding, an agent's question or a wrong premise. Whenever you go back to the user, at an early stop or at the final one, put the whole queue as one round, oldest first. When slice N stops the run, the earlier slices' collected findings come first and slice N's question comes last.

## The whole-branch challenge

Once the last slice is built, note `git merge-base HEAD <default branch>` as `<base>` and the commit you are on as `<built>`. Call the Skill tool with `challenge`, with `<plan path> <base>..HEAD` as its argument, so its plan lens checks the whole branch against every slice and the decision log.

Send its defect findings to the coding agent of the slice each belongs to, resumed with SendMessage as `SKILL.md` describes, and have them applied as the commit style says. Then, when the commit style makes corrections fixups, squash them with `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash --exec '<gate>' <base>`. Nothing is rewritten when the style makes each correction a commit of its own, since the gate has already run on each. When a commit is red, run `git rebase --abort`, run `git reset --hard <built>`, and stop, naming the commit that went red and the kind of failure.

## The stop

Stop once, after all of that. Report:

- every slice built, each with its acceptance test, in one sentence per slice;
- the branch and the commits of `git log --oneline --reverse <base>..HEAD`, not only the last slice's;
- anything an agent could not verify;
- the whole queue of questions, from the slices and from the whole branch, as one round, calling the Skill tool with `grilling`, oldest first.

With `tracker: github`, close every built slice's issue and every removed row's now, as `TRACKER.md` says, and only now: the slices' own stops close none inside this run.

Ask the user to review the commits, and stop.
