# build

The skill that builds a plan's slices serially, each in a fresh subagent, test-first and one commit per behaviour, challenged before it stops for review (ADR 0004).

## Inputs from other features

Requirements the `slice` feature placed on `build`, to be grilled with it:

- It reads the branch from the plan's `**Branch:**` line. It continues on that branch, creates it from the default branch and switches to it when on the default branch, and stops and asks on any other branch. Slicing changes no code, so the branch is created where the first change happens and no empty branch is left behind.
- It reads the default branch from `origin/HEAD` rather than assuming `main`.
- It sets a slice's row to `done` in the slice's own last commit, never in a commit of its own. A slice's range is then found from the plan's history: its head is the last commit that set its row to `done`, and its base is the head of the slice built before it, or the branch's merge-base for the first. While building, it keeps the commit a slice starts from in its own context and challenges `<start>..HEAD`.
- It carries out a `rework` slice from its note (squash, revert or rebuild) in place, behind a green gate, so the slice's commits stay together, then challenges the slice and stops for review.
- With `tracker: github`, it closes a slice's issue, by the plan's `Issue` column, when the slice is done, and closes as "not planned", with a comment naming the slice that absorbed it, the issue of a slice a rework removes.
- It closes the plan only once the user has approved the last slice (ADR 0007), and writes `Closes #<parent>`, from the plan's `**Issue:**` line, into the pull request body. It closes the parent issue itself only when there is no pull request, once the branch has merged.
