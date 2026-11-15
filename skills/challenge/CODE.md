# Attacking a diff

The diff lens sees the diff and the repository's standards, and nothing of the plan or the conversation that produced it. Judge the lines the diff changes against each of these, reading the files it touches wherever the diff alone does not settle a claim.

- **The agent file.** Every rule in `CLAUDE.md` or `AGENTS.md` that the diff breaks.
- **The standards.** Every rule the diff breaks in a file listed under `standards` in `.agents/config.yml`. A listed file that does not exist is a finding.
- **The smell baseline.**
  - A parameter, import, variable or branch that nothing uses.
  - Logic that duplicates what the repository already has.
  - A name that says something the code does not do.
  - A failure that is swallowed, or one that escapes where the code around it does not expect it to.
