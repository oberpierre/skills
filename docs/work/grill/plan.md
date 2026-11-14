# grill

**Branch:** `feature/grill`

The skill that interviews the user until every decision about a feature is made, recording terms and decisions as it goes. Every slice is pinned by eval cases under `evals/grill-*`, run with `claude plugin eval . --case '<case>' --allow-tools Write Edit --scaffold --trust-plugin --no-publish`. A case passes at a score of at least 0.67 (`--threshold 0.67`) and must score above the run without the plugin. The finished skill's cases must lead that run by at least 0.3 on average.

## Slices

| Slice | Behaviour | Acceptance cases | Blocked by | Status | Base | Head |
|---|---|---|---|---|---|---|
| G1 | Interviews in rounds, each question with a recommended answer, then waits, and writes no code | `grill-first-round` | none | done | `5a254d5` | `214576b` |
| G2 | Never asks the user what the repository answers | `grill-first-round` | G1 | done, no skill text | `214576b` | `f16dfaa` |
| G3 | Maps an idea worded as something new onto the mechanism the repository already has | `grill-maps-onto-existing` | G1 | done, no skill text | `2df2ec3` | `b7f381a` |
| G4 | Asks only questions whose prerequisites are settled, builds each round from the last one's answers, and never builds during the session | `grill-second-round` | G1 | done | `b7f381a` | `8592f84` |
| G5 | Records settled terms in `GLOSSARY.md`, and decisions that meet the bar as ADRs | `grill-records-terms` | G1 | todo | | |
| G6 | Ends with a challenge of the plan, whose findings become the last round | `grill-ends-with-challenge` | G5, the `challenge` skill | todo | | |

G2 to G5 each extend the same `SKILL.md`, and nothing else connects them, so their order is the table's. G6 waits for `challenge`, which is built after G5.

## Decision log

- The cases share one fixture, a small repository whose notifications go out by email through a `Notifier` interface, and the idea under test is SMS notifications. The right answer extends what exists, which is the failure `grill` exists to prevent.
- Deterministic graders (`regex`, `file_exists`, `tool_used`, `tool_order`) carry every behaviour with a fixed form. `llm` graders judge only what needs meaning, such as whether the agent stopped and waited.
- G2 pins the property, not the mechanism. Its graders check that the round names the configured provider and asks nothing the repository answers, never how the fact was found. The fixture's `config/channels.toml`, which provisions SMS through Twilio, is the fact a run would otherwise ask about.
- G2 adds no skill text. Run on G1's skill, its graders passed every run, so Claude looks facts up unprompted and a line telling it to would change nothing. Its graders joined `grill-first-round` to guard against a later edit breaking the behaviour. With them that case scored 1.0 on every run with the plugin and 0.78 without (one run without asked for the provider), a lead of 0.22, for $0.67.
- Eval cost is recorded per slice from the eval result's `costUsd`, to estimate what evals cost for future skills.
- The 0.3 lead applies to the average across a skill's cases, not to each case. Both arms receive the same prompt, so the run without the plugin still sees the word "grill" and asks questions unprompted, which caps what a single case can show. A case whose lead stays near zero once the skill is complete marks a part of the skill to cut.
- G1 measured: with the plugin 1.0 on every run, without it 0.75 (it never used the round format), a lead of 0.25. A session cost $0.095 to $0.11 and took 22 to 29 seconds, a judge call about $0.0007, and the full case (three runs in each arm) $0.62 in 2.5 minutes.
- A case is a `case.yaml` with `schema_version: "1.0"`. Its `scaffold_script` must name a file inside the case folder, so each case has a one-line `scaffold.sh` calling `evals/fixtures/scaffold-notifier.sh`, which runs in the session's working directory.
- In the run without the plugin, `/grill` arrives as plain text. Claude says the skill is missing and answers the request directly.

- G3 has its own fixture, `eventbus`: 20 files where shipping publishes an `OrderShipped` event that a `Mailer` subscribes to through `channels/registry.py`, and nothing is named "notification". The prompt asks for "an SMS service". A planted control told to propose a standalone service scored 0 on both graders, so the case can fail.
- G3 adds no skill text. On G1's skill, all three runs named the bus and proposed SMS as another subscriber, the judge passing each 3 to 0, for $0.48. The case is kept as a pin. Its lead over the run without the plugin is measured when the skill is complete. Twenty files is still far from the size of repository where the failure it guards against was seen, which this case cannot reproduce.
- A case built on a `history_file` resumes a recorded session, and the session holds the skill text expanded when it was recorded. The run without the plugin therefore resumes the same instructions, so such a case is judged on its score alone and stays out of the 0.3 average. The recorded expansion has to be rewritten from the current `SKILL.md` whenever the skill changes, or the case tests stale instructions.
- `grill-second-round` resumes a first round recorded on the `notifier` fixture, with the session reduced to its conversation entries: the recording also stored the full API request, the user's email address included, which a public repository cannot carry. Machine paths became `/eval/cwd` and `/plugin`. Its round 1 was recorded under G1's text and was given G4's closing line by hand, so it reads as the current skill would write it.
- G4 was red three ways before it was green. On G1's text, round 2 dropped the round format and restarted its numbering at 1. With rules for later rounds added, every run instead answered the opened question itself and wrote the implementation into its reply, which "change no source file" did not forbid. The rules that closed it: no code in replies either, an opened question goes to the user, and every round ends with a closing line saying what happens next. Green runs scored 1.0, 1.0 and 0.8, the 0.8 being the judge reading a moot-decision note as re-asking. The rule change and the closing line landed together, so which of them did the work is unknown.
- G4 cost $2.31: recording the first round $0.19, four rounds of runs $1.33, and $0.79 rerunning the earlier cases on the changed text, which still passed every run. `--case` takes one pattern, the last one given when repeated.

- G4's first green proved less than its commit claimed. Removing the recording's non-conversation entries broke the `parentUuid` chain a resume walks back along, so the resumed session saw only round 1's text and never the skill. That green came from the closing line added to round 1 and from the user's answers, and the G4 rules in `SKILL.md` went untested. `refresh-history.py` now relinks a broken chain and the gate fails on one. A probe asking the resumed agent to quote the skill confirmed it sees the text once the chain is whole.
- Write, Edit and Bash are gated tools that an eval grants only through `--allow-tools`, so every `writes-nothing` and `edits-nothing` before this point passed because the tool did not exist. Granting Bash needs a sandbox backend (`bubblewrap`), which the devcontainer lacks, so cases run with `--allow-tools Write Edit`.

## Open

- Review the 0.67 threshold after the first full runs, once the judge's noise is visible.
- A `gate.yml` workflow on push to `main` and on pull requests into `main` arrives with the slice that publishes the repository, so its first run happens on GitHub.
