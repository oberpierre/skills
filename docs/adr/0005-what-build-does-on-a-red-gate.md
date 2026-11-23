# What build does on a red gate

When the gate fails and three attempts to fix it have not made it pass, `build` stops. It commits nothing and leaves its changes uncommitted in the working tree, so `git diff` shows exactly what it tried. It never weakens, skips or deletes a test to make the gate pass.

Its report names the failing command, the output that matters, what it tried, and which of three kinds of failure it believes this is:

- **A defect in its own code.** It offers to debug it together in the session, and waits for the user.
- **A wrong premise**, where the plan or a decision contradicts what the code or the data actually does. It puts the question to the user as a `grilling` round in the session, because a decision is wrong and no amount of debugging changes a decision. It adds the answer to the plan's decision log and resumes the agent. When the answer changes a slice's behaviour, it stops and names `/slice` instead. Its report records the question the planning missed, for `retro`.
- **A broken environment**, such as a missing dependency, a service that is down or an expired credential. It says what is missing.

End-to-end tests are an optional `e2e` command in the configuration, run once at the end of each slice before the slice is challenged. A failure there is fixed within the slice like any other.

## Why

An agent working alone against a red gate is most tempted to weaken the test, and a weakened test is the worst outcome for review because the commit then looks attested. A review of the slice's diff cannot reliably catch it, since the test was usually written in the same slice and the diff shows only its final, weaker form. Prevention is cheaper than detection, which would mean rebuilding the slice.

Three attempts is enough to fix a mistake and few enough to stop guessing. The classification exists because the remedies differ, and debugging a wrong decision wastes the attempt.
