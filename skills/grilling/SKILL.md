---
name: grilling
description: Ask the user, in numbered rounds with a recommended answer each, until every decision a subject raises is made. Use when a skill or task needs the user to decide something with more than one defensible answer.
argument-hint: "[what to grill]"
metadata:
  credits:
    based-on: grilling
    author: Matt Pocock
    url: "https://github.com/mattpocock/skills"
---

# Grilling: $ARGUMENTS

Ask the user until every decision this subject raises is made. A decision is an answer to a question with more than one defensible answer. The user makes each one, and you recommend.

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

When nothing is open, stop asking. If a skill called for the grilling, go on with its next step, which lists the decisions. Otherwise list them for the user to confirm.
