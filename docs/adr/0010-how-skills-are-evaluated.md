# How skills are evaluated

A skill's behaviour is pinned by eval cases in `evals/<skill>-*`, but no case runs live while a skill is being built. A slice writes its cases and checks each grader offline, against saved traces where they exist and otherwise against simulated output that should pass it and output that should fail it. The whole suite runs live once before a release, after every skill of that release is in, with `evals/run.sh`. The user raises `EVAL_BUDGET_USD` for that run, since it spans several five-hour windows. A later release runs `evals/run.sh --changed <previous release tag>`, which runs only the cases of the skills changed since that tag.

A case is cheap to write and costly to run, so cases are shaped for few runs. A new property is graded on an existing case whose setup already reaches it, and two cases stay separate only when their setups cannot share one run. Graders stay independent of each other, so one early miss does not zero the rest. A skill adapted from another source with little logic of its own, such as `pr`, `prototype`, `wait-what` and `diagnosing-bugs`, ships no cases.

The pre-release run starts with one case and confirms from its trace that the case ran on the models it was routed to, before the rest are spent.

## Why

Evals spend the same usage limit as feature work. Before this rule, one slice's red and green runs took nearly a whole five-hour window, and one run of a single skill's cases would have taken about eight. Both features built under the earlier per-slice rule had to override it to finish at all.

Running once before a release still catches what offline checks cannot, such as a grader that passes blind or an instruction a model does not follow, and it catches them before users install the version. What is lost is the red run before the skill text, which showed that a case fails without the text that should turn it green. An offline check of each grader against output that should fail it stands in for that.

The adapted skills follow sources that ship no evals, and they reshape text more than they decide anything, which is where a case pins least.

## History

**2026-11-23.** The rule was a red run with a baseline arm and a green run of three runs per slice, then a rerun of every changed skill's cases at the end of each slice. It was replaced because one run of the `build` feature's cases alone would have needed eight five-hour windows.
