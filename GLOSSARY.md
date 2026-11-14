# oberpierre-skills

Agent skills for building software in small, reviewed steps, where the user makes the decisions and the agent does the work between them.

## Language

### Deciding

**Decision**:
An answer to a question with more than one defensible answer. The user makes it, and the agent recommends one.
_Avoid_: choice, call

**Fact**:
Something the code, the data or a tool's behaviour can settle. Finding one is the agent's job.
_Avoid_: assumption

**Grilling**:
An interview in rounds, each asking every question whose prerequisites are settled, with a recommended answer per question.
_Avoid_: Q&A, discovery

**Round**:
One batch of grilling questions, asked together and answered before the next batch is worked out.

**Decision log**:
The decisions of one feature, kept in its plan.
_Avoid_: notes, decision record

**ADR**:
A decision promoted out of a decision log because it is cross-feature, hard to reverse or surprising.

**Glossary**:
A project's domain language, one entry per term.
_Avoid_: context file, dictionary

### Planning

**Feature**:
A body of work with one plan, one branch and one pull request.
_Avoid_: epic, project

**Plan**:
The file holding a feature's slices, their status and commit ranges, and its decision log. It is deleted when the feature is done.
_Avoid_: spec, ticket list

**Slice**:
One behaviour built end to end and pinned by an acceptance test, delivered as one or more commits.
_Avoid_: task, ticket, story

**Acceptance test**:
The test that shows a slice's behaviour works, named in the plan before the slice is built.

**Seam**:
The public boundary a test observes behaviour through, without reaching inside.

### Building

**Gate**:
The repository's full check command. A green gate is what earns a commit its validated marker.
_Avoid_: CI, checks

**Stop**:
An agent halting to ask, because it met a question no recorded decision answers.
_Avoid_: block, escalation

**Fixup**:
A correction folded into the commit it corrects, before the user reviews it.

**Lesson commit**:
A correction kept in history as its own commit, because it records a discovery.

**Commit style**:
The file stating how commit messages are written in a repository.
_Avoid_: commit template

### Reviewing

**Challenge**:
An adversarial review from a context that never saw how the artifact was made. A plan challenge attacks a plan, and a code challenge attacks a slice's diff.
_Avoid_: review pass, critique

**Lens**:
One view a code challenge takes. The diff lens sees only the diff, and the plan lens sees the diff with its slice and decisions.
_Avoid_: reviewer

**Gotcha**:
A surprise about a tool or the codebase, recorded in the agent file so the next agent is spared it.
_Avoid_: field guide entry, tip
