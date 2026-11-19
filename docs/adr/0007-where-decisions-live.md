# Where decisions live

Each feature has a plan at `docs/work/<feature>/plan.md`, holding its slices, their status, and a decision log. A decision goes into that log by default. It is promoted to an ADR in `docs/adr/` only when all three hold: it is hard to reverse, it would surprise a later reader, and it was the result of a real trade-off between alternatives.

The plan is committed on the feature branch with the first slice, and it is the source of truth for `build` whichever tracker is configured. When the last slice is done and the user has reviewed and approved it, `build` closes it. It checks each logged decision once more and promotes the ones that now meet the bar for an ADR. It writes the rest into the pull request body under `## Decisions`, or into the merge commit's message when there is no pull request. Then it deletes the plan in a final commit, `. d Close the <feature> plan`. The plan stays readable in the branch's history.

`GLOSSARY.md` holds the project's domain language and nothing else: one entry per term, with the words to avoid. It is committed. A project that wants it local adds it to `.gitignore` by hand, and no configuration key exists for that.

Surprises about tools and the codebase go into a `## Gotchas` section of the agent file (`CLAUDE.md` or `AGENTS.md`), under a line budget the section states. There is no separate field guide.

The tracker is local Markdown by default, meaning the plan alone. GitHub Issues is an option when `setup` finds `gh` available, and it mirrors the plan rather than replacing it: one issue per slice, with native blocking links, closed when the slice is done and linked from the pull request. The slices' issues are sub-issues of one parent issue for the feature, which the pull request body closes with `Closes #<parent>` when it merges. The decision log and the slices' status stay in the plan.

## Why

An ADR for every decision more than one unit of work depends on produces dozens of them, and a reader can no longer tell which ones matter. Requiring all three conditions keeps out the ordinary choices a reader would make anyway, which no reader needs explained. The plan's log keeps a feature's decisions next to the slices that use them, and promotion keeps the ADR directory for what outlives the feature.

A glossary makes names in code, tests and conversation agree, and an agent that shares the project's vocabulary needs fewer words to say the same thing.

A field guide injected beside the agent file is a second always-loaded store competing for the same budget. One section of the agent file makes the cost visible where it is paid.

An issue tracker is good at showing progress and blocked work, and bad at state that `build` rewrites, such as a slice's status during a rework. Keeping that state in one file means two stores cannot disagree. A slice's commits are found from the plan's history only while the branch is unmerged, since a squash or rebase merge gives them new identities, so the plan has served its purpose once the branch merges. Its decisions are what outlive it, which is why they move before it is deleted. Issues record what each slice did, and they do not record why.

Local Markdown works offline and in repositories that keep agent material out of version control, which suits solo projects better than a tracker does.

## History

**2026-11-14.** The bar used to be "cross-feature, hard to reverse or surprising to a later reader", any one sufficing. An eval of `grill` showed it was too loose: from one round of ten answers, the agent wrote two or three ADRs, among them one for reading credentials from environment variables, which is ordinary practice. With all three conditions required, it wrote at most one.

**2026-11-15.** `build` used to close the plan as soon as the last slice was done. A challenge of the `slice` plan showed that this deletes the plan before the user's review of a whole feature, which is when rework is found, so a rework request through `slice` would find no plan. The close now waits for the user's approval.

**2026-11-19.** The `slice` feature added a parent issue per feature, and first had `build` close it together with the plan. That would show the feature done while its pull request is still open, so the parent now closes when the pull request merges. Deleting the plan as soon as the last slice passes `build`'s challenge, before the user's review, was weighed again and rejected for the reason of 2026-11-15: every rework found in review would first have to restore the plan.
