# Mirroring slices to GitHub Issues

The plan stays the source of truth, and each slice's issue only mirrors its row (ADR 0007). An issue is read by people who never see the plan, which is deleted once the feature is merged, so every issue must make sense on its own: give it a short title in the terms of `GLOSSARY.md`, paraphrasing the row rather than copying it, and open its body with a few plain sentences on what it adds for whoever uses it and why. Run these commands through Bash, one call per command, and read each issue's number from the URL `gh issue create` prints.

## Before the first issue

Run `gh repo view --json nameWithOwner`, and when the repository is not the one the plan belongs to, such as a fork's parent, ask before creating anything.

## First run: the table has no `Issue` column

First create the feature's parent issue, titled and described from the plan's summary, its body ending with a `Feature: <the plan's folder name>` line:

```
gh issue create --title "<title>" --body "<description>

Feature: <slug>"
```

Then create one issue per slice, in the table's order, so that a slice's blockers already have numbers, each a sub-issue of the parent:

```
gh issue create --title "<Behaviour>" --body "<body>" --parent <parent> [--blocked-by <n>,<n>]
```

- The title says what the slice adds, from its Behaviour.
- The body is the description, then three lines: `Acceptance test: <the Acceptance test cell>`, `Feature: <the plan's folder name>`, `Slice: <id>`. A Blocked by entry that is not a slice id goes into the body as one more line, `Blocked by: <entry>`, and gets no link.
- `--blocked-by` lists the issue numbers of the slice ids in Blocked by, and is left out when there are none.

Then close the issue of every `done` slice with `gh issue close <n> --reason completed`.

Add an `Issue` column to the table, after `Note`, holding `#<n>` for each slice, and write a `` **Issue:** #<parent> `` line under the plan's `**Branch:**` line. The parent stays open until `build` closes the plan.

## Later runs: the table has an `Issue` column

Find an issue only by the number in the plan, the slice's `Issue` cell or the `**Issue:**` line, never by searching GitHub.

- A slice this run changed keeps its issue: rewrite its title and body from the new row as on the first run, with `gh issue edit <n> --title "<title>" --body "<body>"`.
- A slice this run added gets an issue as on the first run, a sub-issue of the parent, and its number in the `Issue` column.
- Leave every other issue as it is, even when it differs from its row, since this run did not change that slice.
