extends: arlo

# Arlo's Commit Notation for feature development

## Risk

`^` is earned by one behaviour pinned by a test with the gate green, whatever the line count.

## Intention

`t` marks a commit that changes only tests, either pinning behaviour that already exists or repairing a test found after it reached the main branch.

## Corrections

A correction that records a discovery stays a commit of its own. A correction of a review finding becomes a fixup of the commit it corrects, made with `git commit --fixup=<commit>`, and is squashed into it before the user reviews the slice.
