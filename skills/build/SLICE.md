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
4. Run the gate on its own, read its exit status, and commit only when it passes, in a separate command and with a message in the commit style. A commit in the same command as the gate, or after a pipe that hides the gate's status, commits red code.

A commit changes one behaviour and carries the test that pins it. Most slices are one or two commits. Never commit with `--no-verify`, and never weaken, skip or delete a test to make the gate pass.

When the plan file is not yet committed, add it to the slice's first commit.

## End-to-end check

When the message gives an `E2E` command, run it once, after the slice's last behaviour passes the gate and before you commit it. Never run it earlier or again for a green result. When it fails, fix the cause within the slice, as a change to the code or a test that belongs to the slice, run the gate, and run `E2E` once more. Commit when both pass.

## A red gate

When the gate fails after a change to the code, fix the cause and run it again. The red you expect before writing code does not count, and only failures after a code change do: stop at the third, per behaviour. The same cap covers a failing `E2E` command. Stop at once, without spending attempts, when you see before or during your first attempt that the plan or a decision contradicts the code or the data.

When you stop, commit nothing for the behaviour that is red and leave its changes in the working tree. Behaviours that went green earlier stay committed. Never weaken, skip or delete a test, or change the gate, to turn it green.

Reply with the failing command, the output that matters, what you tried, the commits already in `<start>..HEAD`, and the kind of failure you believe it is:

- **a defect in your own code**;
- **a wrong premise**, where the plan or a decision contradicts what the code or the data does: quote both sides, and put the question the user must answer;
- **a broken environment**, such as a missing dependency, a service that is down or an expired credential: say what is missing.

## A question no decision answers

When the behaviour needs a choice the plan and its decision log do not make, such as where a piece of data lives or which of two designs to follow, do not choose it yourself. When no decision in the plan answers it, commit nothing for the behaviour that needs the choice, leave any changes in the working tree, and reply with:

- `Question:` and the question, with the options you see and the one you would recommend;
- the commits already in `<start>..HEAD`.

## Answer:

When the message gives `Answer:`, the user has answered that question, and the plan's decision log now holds the answer. Read the decision log again, keep your changes in the working tree, and carry on building the behaviour. The plan edit is uncommitted, and your next commit includes it.

## Premise answer:

When the message gives `Premise answer:`, the user has answered the question you stopped on, and the plan's decision log now holds the answer. Read the decision log again, keep your changes in the working tree, and build the behaviour again with a fresh count of three attempts. The plan edit is uncommitted, and your next commit includes it.

## Done

In the slice's last commit, set the slice's Status in the plan's table to `done`, changing nothing else in the plan. Never mark it in a commit of its own.

Then reply with:

- the commits, as `git log --oneline --reverse <start>..HEAD` prints them;
- the acceptance test and the assertion that pins the behaviour;
- anything you could not verify.

## Findings

When the message gives `Findings:`, they are defects a challenge found in your slice. For each, in order:

1. Write the test that shows it first, when it is a behaviour, and see it fail.
2. Fix it, run the gate, and commit as the commit style says for a correction, which under a style that makes corrections fixups is `git commit --fixup=<the commit that introduced it>`. Leave the squash to the one who started you.
3. Run the gate again.

Finish with the plan's row for the slice set to `done` in the slice's real last commit: when a correction stays a commit of its own, move the change onto it, so no earlier commit sets `done`. Reply as above.
