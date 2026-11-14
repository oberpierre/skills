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

You write no code and change no source file during a grilling session. Building comes after the session, in a separate step.

## Rounds

Work in rounds. A round asks every open question at once, numbered, each with your recommended answer. Then stop and wait for the user's answers before working out the next round.

Format a round exactly like this:

```
❓ **Q1 – <short title>:** <the question, with the options where they matter>
➡️ <your recommended answer, and why in one sentence>

❓ **Q2 – <short title>:** ...
➡️ ...
```

Word each question so that "yes" accepts your recommendation.

## Ending

The session is done when no open question is left. Do not act on the decisions until the user confirms that.
