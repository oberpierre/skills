# Build runs serially, one fresh subagent per slice

`build` builds the slices of a plan one after another, in the order the plan gives. Each slice runs in a fresh subagent that receives pointers only: the plan's path, the slice's id and the commit the slice starts from. The session that runs `build` holds the subagents' reports and nothing else.

The argument decides the scope. `/build S3` builds one slice, has it challenged, applies the fixes and stops for the user's review. `/build <feature>` builds every remaining slice, challenges each, runs one challenge over the whole branch at the end and stops once. With no argument, `build` lists the slices with their status and suggests the next one.

No commit range is recorded. `build` keeps the commit a slice starts from in its own context and challenges `<start>..HEAD` once the slice is built. It sets the slice's row in the plan to `done` in the slice's own last commit, so a slice found later runs from the commit that marked the slice before it `done` to the last commit that marked it `done`, and a rework rewrites a slice in place. The range of a whole feature starts at the merge-base with the default branch.

## Why

Parallel slices in one working tree break the attestation a commit carries. Each agent runs the gate with the other's unfinished edits on disk, so a green gate no longer says anything about the commit it precedes. Files that do not overlap are no guarantee of independence either, and history written in the order slices happened to finish needs reordering by hand. Separate worktrees rebased in plan order would solve both, at the cost of machinery a solo project rarely earns back. A `retro` finding that serial building is too slow is what reopens this.

A fresh subagent per slice keeps each slice's context free of the previous one's exploration, and it keeps the orchestrating session small enough to stay sharp across a whole feature.

Serial building keeps each slice's commits together, so git answers which commits are a slice's without a record, which would go stale on every squash or rebase.

One skill covers both scopes, because an argument that shows its scope is one less name to remember.
