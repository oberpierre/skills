# Build pushes only at close

`build` never pushes while slices are being built, reworked or corrected by a review comment. It pushes the feature branch once, at close, to open the pull request, and never with `--force`. When the branch lands by a local merge instead, nothing is pushed at all, the default branch included.

## Why

Before close, `build` rewrites the branch freely: fixups are squashed, reworks drop or rebuild commits, and review comments become fixups. A branch that was already pushed would need a force-push after each of those, and a force-push to a shared remote is exactly the step a user should take by their own hand.

The cost is that the feature's work has no remote backup until close, so a lost machine loses the unpushed slices. A user who wants a backup pushes the branch themselves, and force-pushes it after the next rewrite.
