---
name: grill
description: Interview me about a feature idea, in rounds of questions with your recommended answers, until every decision is made. Nothing gets built during it.
argument-hint: "[the idea or feature to grill]"
disable-model-invocation: true
metadata:
  credits:
    based-on: grill-with-docs
    author: Matt Pocock
    url: "https://github.com/mattpocock/skills"
---

# Grill: $ARGUMENTS

Interview the user until every decision this idea raises is made. Call the Skill tool with `grilling`, with the idea as its argument, and ask every round as it says.

You write no code during a grilling session: no code in your replies for the user to apply, and no file changes other than the records described under Recording and the plan described under Ending. Building comes after the session, in a separate step.

## Recording

Record as soon as an answer settles something, before asking the next round, rather than at the end.

**A term.** When an answer fixes what a word means in this project, add it to `GLOSSARY.md` at the repository root, creating the file if it does not exist. One entry per term, defining what it is in one or two sentences, with the words to avoid:

```
**Channel**:
One way of reaching a customer, such as email or SMS.
_Avoid_: medium, transport
```

**An ADR.** When a decision is hard to reverse, would surprise a later reader and was a real trade-off between alternatives, all three, write it to `docs/adr/NNNN-<slug>.md`, numbered one past the highest there. Its title states the decision, and one paragraph gives the context and the reason the user gave. Every other decision goes into the plan when the session ends.

## Ending

When you believe no open question is left, the plan comes before the list of decisions.

1. **Write the plan.** Name the feature with a short kebab-case slug, and tell the user the slug so they can rename it. Write the decisions to `docs/work/<slug>/plan.md` under `## Decision log`, one entry each: the decision in one sentence, the reason the user gave, and the alternative they rejected where one was weighed. If the file exists, add to its decision log and leave the rest of it as it is. Do not commit it.
2. **Challenge it.** Call the Skill tool with `challenge`, with the plan's path as its only argument.
3. **Ask its findings.** Put every finding to the user as one more round, in the round format with its numbering continued, each title starting with `Challenge:`. Phrase a defect as "Fix as stated?". Where you disagree with a finding, recommend dismissing it and say why. If there are no findings, say so and go on to the list.

Challenge the plan once per session. Record the answers to the findings round in the plan like any others. When no question is left, list the decisions and wait for the user to confirm. Do not act on the decisions until they do.
