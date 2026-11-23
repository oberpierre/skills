# The gate reruns on every rewritten commit

Whenever `build` rewrites history, squashing a slice's fixups, carrying out a rework or folding a review comment, it runs the gate on every commit the rewrite produces, with `git rebase -i --exec '<gate>'`, and not only on the new tip. When one commit goes red, `build` runs `git rebase --abort`, restores the branch to exactly the commit it was on before the rewrite, and stops, naming the commit that went red and the kind of failure. It never tries to fix a red commit mid-rebase. The cost is accepted even for a slow gate, such as a Bazel build, where a one-line fixup early in a long branch reruns it once per later commit.

## Why

ADR 0002 makes the commit the unit of review, and a commit attests that the gate passed on it by itself. A rewrite changes every commit after the one it touches, so a green tip says nothing about the commits beneath it, and a reviewer reading them one at a time would be reading unattested states.

Fixing mid-rebase applies ADR 0005's three remedies inside an operation that can be left half done, so a mistake there leaves the repository partly rewritten. Aborting returns to a state that was already green, and the user decides what happens next.
