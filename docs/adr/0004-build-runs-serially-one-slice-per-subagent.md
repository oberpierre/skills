# Build runs serially, one fresh subagent per slice

`build` builds the slices of a plan one after another, in the order the plan gives. Each slice runs in a fresh subagent that receives pointers only: the plan's path, the slice's id and the commit the slice starts from. The session that runs `build` holds the subagents' reports and nothing else.

The argument decides the scope. `/build S3` builds one slice, has it challenged, applies the fixes and stops for the user's review. `/build <feature>` builds every remaining slice, challenges each, runs one challenge over the whole branch at the end and stops once. With no argument, `build` lists the slices with their status and suggests the next one.

The plan records a `Base` and a `Head` commit for each slice, so `git log -p <base>..<head>` shows exactly one slice. When a rewrite crosses slices, `build` re-records both by matching commit subjects. The range of a whole feature starts at `git merge-base main HEAD`.

## Why

Parallel slices in one working tree break the attestation a commit carries. Each agent runs the gate with the other's unfinished edits on disk, so a green gate no longer says anything about the commit it precedes. Files that do not overlap are no guarantee of independence either, and history written in the order slices happened to finish needs reordering by hand. Separate worktrees rebased in plan order would solve both, at the cost of machinery a solo project rarely earns back.

A fresh subagent per slice keeps each slice's context free of the previous one's exploration, and it keeps the orchestrating session small enough to stay sharp across a whole feature.

Recording commit ranges in the plan rather than in commit trailers keeps messages clean, since git can already answer the question when given two commits.

## Considered options

- **Parallel slices when their expected files do not overlap.** Rejected for the reasons above. A `retro` finding that serial building is too slow is the trigger to revisit it.
- **Two skills, one per scope.** Rejected because one skill whose argument shows its scope is one less name to remember.
