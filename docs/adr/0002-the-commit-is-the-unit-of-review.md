# The commit is the unit of review

A commit changes one behaviour, a test pins that behaviour, and the repository's full gate is green before the commit is made. `build` enforces this and offers no setting to relax it. Someone who wants otherwise forks the repository.

A slice is one or more such commits, and the user reviews a slice by reading its commits in order. The commit style (see ADR 0003) decides how a commit's message is written, and it cannot change what a commit contains.

## Why

The user reviews agent work, and the commit log is the record they read. A small commit with one stated intention can be checked against its diff in one sitting, whereas a large one asks the reviewer to reconstruct which hunk serves which purpose. Small green commits also suit a reviewer who squash-merges, because they make the pull request easier to read before the squash happens.

Line count is not the limit. A feature that adds a dependency and its first use changes more than a handful of lines and is still one behaviour. Lockfiles, generated files and fixtures do not count toward a commit's size at all. A commit too large to review in one sitting is a smell the agent must justify, never a rule it can satisfy by counting.

## Considered options

- **Leaving granularity to the commit style.** Rejected because granularity is what makes the commit the unit of review, and without it `build` adds nothing to an agent committing at will.
- **A line limit, as Arlo's Commit Notation has for its validated level.** Rejected for the reason above. The limit was set for refactoring in code that is already fully tested.
