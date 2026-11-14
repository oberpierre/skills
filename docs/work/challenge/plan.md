# challenge

**Branch:** `feature/challenge`

The skill that attacks a plan or a diff from a context that never saw it being made (ADR 0006), and the end of `grill` that calls it. Every slice is pinned by eval cases, run with `claude plugin eval . --case '<case>' --allow-tools Write Edit --scaffold --trust-plugin --no-publish --threshold 0.67`. A case passes at a score of at least 0.67 and, unless it resumes a history, must score above the run without the plugin.

## Slices

| Slice | Behaviour | Acceptance cases | Blocked by | Status | Base | Head |
|---|---|---|---|---|---|---|
| C1 | A plan challenge reports a plan that builds a second mechanism beside an existing one, as a finding with kind, location and evidence, and edits nothing | `challenge-plan-second-mechanism` | none | done | `b23618a` | |
| C2 | A plan challenge reaches its verdict without the caller's conversation, even one that argued for the flaw | `challenge-ignores-the-conversation` | C1 | todo | | |
| C3 | The diff lens judges a range's diff against the agent file, the `standards` key and the smell baseline in `CODE.md` | `challenge-diff-against-standards` | C1, a Bash-capable eval environment | todo | | |
| C4 | `grill` ends by writing the decision log to the plan, calling `challenge` on it, and asking its findings as a `Challenge:` round before listing the decisions | `grill-ends-with-challenge` | C1 | todo | | |

C4 is G6 of the grill plan, moved here because it depends on this skill. The plan lens, and the plan attacks that need slices (whether a proof can pass while the defect survives, what falls between slices), wait for `slice` and `build`, whose plan format does not exist yet.

## Decision log

- Scope is the plan subject and the diff lens. The plan lens and the slice-level attacks are deferred, because there is no slice format to attack and they cannot be run red first.
- When nothing is open, `grill` writes the decision log to `docs/work/<feature>/plan.md`, uncommitted, and calls `challenge` with that path. Pointers, not pasted content (ADR 0008), and the file is the one `slice` later extends.
- The challenge runs once `grill` believes nothing is open, before it lists the decisions, so that what the user confirms includes the answers to the findings. One challenge per session, and the user can call `/challenge` again.
- A finding states its kind (**defect**, settled by a fact, or **question**, needing a decision), its location (`file:line` or the plan entry), its evidence and what is wrong. Findings are ranked by severity with no cap, a claim without evidence is left out, and "no findings" is a valid result. The kinds map onto ADR 0001's fact and decision split, so each caller knows what to do with a finding.
- `grill` puts every finding to the user as a numbered question with its recommendation, recommending "dismiss, because …" where it disagrees. It never filters silently, since dropping a finding is itself a decision.
- The argument decides the subject: a path to a plan file is a plan challenge, a commit range is the diff lens, and no argument is the diff lens over the branch since `git merge-base main HEAD`. A bad argument is reported and the skill stops.
- `challenge` sets `model: opus`, being the most reasoning-heavy skill in the set.
- The diff lens judges against the agent file (`CLAUDE.md` or `AGENTS.md`), any files listed under `standards` in `.agents/config.yml`, and the smell baseline in `CODE.md`.
- `grill` derives the feature slug and says it when it writes the plan, so the user can rename it there.
- A decision log entry is the decision in one sentence, the user's reason, and the rejected alternative where one was weighed.
- When the plan file already exists, `grill` adds to its decision log and leaves the rest untouched, so a re-grill after `slice` keeps the slices.
- The findings round uses the normal round format with numbering continued, each title starting `Challenge:`. A defect is phrased as "fix as stated?".
- A direct `/challenge` prints its findings and writes nothing.
- Four eval cases pin the feature: `challenge-plan-second-mechanism`, `challenge-ignores-the-conversation`, `challenge-diff-against-standards` and `grill-ends-with-challenge`.
- A `context: fork` skill sees its arguments and none of the conversation, for a model call and a typed command alike. ADR 0006 records the probe.
- In this devcontainer, Docker's default seccomp profile blocks `unshare`, so `bwrap` cannot create a namespace even when installed, and every Bash command in an eval fails inside the sandbox. A `` !`git …` `` line in a skill runs outside that sandbox, needs `--allow-tools 'Bash(git:*)'`, and is refused when it holds `$(…)`. `$ARGUMENTS` is substituted into it. C3 waits on how this is resolved.

- C1 ran red with no skill at 0.8 on every run: unprompted, Claude reported the second mechanism with a location but never named a finding's kind. With the skill, 1.0 on every run, against 1.0, 0.8 and 0.6 without it (one baseline run missed the second mechanism). The attack lines in `PLAN.md` are ADR 0006's list, and only the kind and the form were shown to need text. C1 cost $1.49.
- A forked skill's tool calls appear in the eval trace as subagent calls, and `tool_used` graders count them. `reads-the-code` pins that, so `writes-nothing` cannot pass merely because the fork's calls are invisible.

## Open

- Which lines of `PLAN.md` change what a plan challenge finds. Only the second mechanism has a case, and it was found without the line.

- How the diff lens gets its diff in an eval: the container run with `seccomp=unconfined` so Bash works, or the skill injecting the diff with `` !`git diff $ARGUMENTS` ``.
