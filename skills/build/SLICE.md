# Building one slice

You build one slice of a feature's plan. The message that pointed you here gives the plan, the slice id, the commit the slice starts from, the gate command and the commit style file, and optionally an `E2E` command. You work on the branch you are on: switch, create or push no branch.

## Read first

- The plan: the slice's row in its slices table, and its decision log. The decisions are made, so build what they say.
- The agent file, `CLAUDE.md` or `AGENTS.md`, wherever the repository has one.
- The commit style file, and the file it `extends:`, if any.
- The code the slice touches, through the seam its acceptance test names.

## Test first, one behaviour per commit

The slice's acceptance test is named in its row, with the seam it observes the behaviour through. For each behaviour, in order:

1. Write the test first, through the seam. For the slice's main behaviour, that is the acceptance test, under the name the row gives.
2. Run the gate and see the new test fail, for the reason the behaviour is missing.
3. Write the least code that makes it pass.
4. Run the gate. Commit only when it passes, with a message in the commit style.

A commit changes one behaviour and carries the test that pins it. Most slices are one or two commits. Never commit with `--no-verify`, and never weaken, skip or delete a test to make the gate pass.

When the plan file is not yet committed, add it to the slice's first commit.

## End-to-end check

When the message gives an `E2E` command, run it once, after the slice's last behaviour passes the gate and before you commit it. Never run it earlier or again for a green result. When it fails, fix the cause within the slice, as a change to the code or a test that belongs to the slice, run the gate, and run `E2E` once more. Commit when both pass.

## Done

In the slice's last commit, set the slice's Status in the plan's table to `done`, changing nothing else in the plan. Never mark it in a commit of its own.

Then reply with:

- the commits, as `git log --oneline --reverse <start>..HEAD` prints them;
- the acceptance test and the assertion that pins the behaviour;
- anything you could not verify.
