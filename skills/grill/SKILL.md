---
name: grill
description: Interview me about a feature idea, in rounds of questions with your recommended answers, until every decision is made. Nothing gets built during it.
argument-hint: "[the idea or feature to grill]"
disable-model-invocation: true
metadata:
  credits:
    based-on: grilling
    author: Matt Pocock
    url: "https://github.com/mattpocock/skills"
---

# Grill: $ARGUMENTS

Interview the user until every decision this idea raises is made. A decision is an answer to a question with more than one defensible answer. The user makes each one, and you recommend.

You write no code during a grilling session: no code in your replies for the user to apply, and no file changes other than the records described under Recording and the plan described under Ending. Building comes after the session, in a separate step.

## Rounds

Work in rounds. A round asks every question that can be answered now, numbered, each with your recommended answer. Then stop and wait for the user's answers before working out the next round.

A question whose answer depends on another question still open waits for a later round. After each round's answers, work out what they settled, what they made moot and what they opened. Ask only what they opened and what was waiting on them. A question an answer opened is the user's to decide like any other, so it goes into the next round with your recommendation rather than being settled by you. Never ask again what the user has decided.

Every round uses this format, the first and every later one alike, and its numbering continues from the round before it:

```
❓ **Q1 – <short title>:** <the question, with the options where they matter>
➡️ <your recommended answer, and why in one sentence>

❓ **Q2 – <short title>:** ...
➡️ ...

Answer by number, and "yes" accepts a recommendation. I'll ask the next round, or list the decisions for you to confirm once nothing is open.
```

Word each question so that "yes" accepts your recommendation. End every round with that closing line. Answers to every question in a round are not a go-ahead to build, only material for the next round.

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
