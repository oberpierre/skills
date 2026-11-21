# Where decisions live

Each feature has a plan at `docs/work/<feature>/plan.md`, holding its slices, their status, and a decision log. A decision goes into that log by default. It is promoted to an ADR in `docs/adr/` only when all three hold: it is hard to reverse, it would surprise a later reader, and it was the result of a real trade-off between alternatives.

The plan is committed on the feature branch with the first slice, and it is the source of truth for `build` whichever tracker is configured. When the last slice is done and the user has reviewed and approved it, `build` closes it. It suggests the logged decisions that now meet the bar for an ADR, each with its reason, and promotes the ones the user picks, since whether a decision would surprise a later reader is the user's judgement (ADR 0001). It writes the rest into the pull request body under `## Decisions`, or into the merge commit's message when there is no pull request. Then it deletes the plan in a final commit written in the configured commit style, such as `. d Close the <feature> plan`, before it pushes the branch and opens the pull request. The plan stays readable in the branch's history.

`GLOSSARY.md` holds the project's domain language and nothing else: one entry per term, with the words to avoid. It is committed. A project that wants it local adds it to `.gitignore` by hand, and no configuration key exists for that.

Surprises about tools and the codebase go into a `## Gotchas` section of the agent file (`CLAUDE.md` or `AGENTS.md`), under a line budget the section states.

The tracker is local Markdown by default, meaning the plan alone. GitHub Issues is an option when `setup` finds `gh` available, and it mirrors the plan: one issue per slice, with native blocking links, closed when the slice is done and linked from the pull request. The slices' issues are sub-issues of one parent issue for the feature, which the pull request body closes with `Closes #<parent>` when it merges. The decision log and the slices' status stay in the plan.

## Why

An ADR for every decision more than one unit of work depends on produces dozens of them, and a reader can no longer tell which ones matter. Requiring all three conditions keeps out the ordinary choices a reader would make anyway, which no reader needs explained. The plan's log keeps a feature's decisions next to the slices that use them, and promotion keeps the ADR directory for what outlives the feature.

A glossary makes names in code, tests and conversation agree, and an agent that shares the project's vocabulary needs fewer words to say the same thing.

Notes the agent always loads compete for one budget, and one section of the agent file makes their cost visible where it is paid.

An issue tracker is good at showing progress and blocked work, and bad at state that `build` rewrites, such as a slice's status during a rework. Keeping that state in one file means two stores cannot disagree. A slice's commits are found from the plan's history only while the branch is unmerged, since a squash or rebase merge gives them new identities, so the plan has served its purpose once the branch merges. Its decisions are what outlive it, which is why they move before it is deleted. Issues record what each slice did, and they do not record why.

The plan is closed only once the user has approved the last slice, not as soon as it is built: review is when rework is found, and a rework needs the plan. The parent issue closes when the pull request merges, because a feature is done when it is merged.

Local Markdown works offline and in repositories that keep agent material out of version control, which suits solo projects better than a tracker does.
