# Attacking a diff

The diff lens sees the diff and the repository's standards, and nothing of the plan or the conversation that produced it. Judge the lines the diff changes against each of these, reading the files it touches wherever the diff alone does not settle a claim.

- **The agent file.** Every rule in `CLAUDE.md` or `AGENTS.md` that the diff breaks.
- **The standards.** Every rule the diff breaks in a file listed under `standards` in `.agents/config.yml`. A listed file that does not exist is a finding.
- **The smell baseline.**
  - A parameter, import, variable or branch that nothing uses.
  - Logic that duplicates what the repository already has.
  - A name that says something the code does not do.
  - A failure that is swallowed, or one that escapes where the code around it does not expect it to.

## The plan lens

When the argument names a plan, the code challenge has a second lens beside the diff lens. Run the diff lens in a subagent that is given only the range and the path to this file, so that it never sees the plan, and run the plan lens yourself. Report both lenses' findings as one list.

The plan lens sees the diff with the slice's row and the decisions it carries out, or with every slice and decision when no slice id is given. For each acceptance criterion, meaning each thing the row's behaviour promises, name the assertion in the diff that pins it, as `file:line` with the assertion's text, and say whether it would fail if that criterion were wrong. A criterion with no assertion, or only one that would still pass, is a defect, and the finding names the criterion and the missing assertion. A diff that contradicts a decision is a finding too.
