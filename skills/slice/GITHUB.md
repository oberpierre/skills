# Mirroring slices to GitHub Issues

The plan stays the source of truth, and each slice's issue only mirrors its row (ADR 0007). Run these commands through Bash, one call per command, and read each issue's number from the URL `gh issue create` prints.

## Before the first issue

Run `gh repo view --json nameWithOwner`, and when the repository is not the one the plan belongs to, such as a fork's parent, ask before creating anything.

## First run: the table has no `Issue` column

First create the feature's parent issue, titled with the plan's one-line summary under its title, with `Feature: <the plan's folder name>` as its body:

```
gh issue create --title "<summary>" --body "Feature: <slug>"
```

Then create one issue per slice, in the table's order, so that a slice's blockers already have numbers, each a sub-issue of the parent:

```
gh issue create --title "<Behaviour>" --body "<body>" --parent <parent> [--blocked-by <n>,<n>]
```

- The title is the row's Behaviour, without its backticks.
- The body is three lines: `Acceptance test: <the Acceptance test cell>`, `Feature: <the plan's folder name>`, `Slice: <id>`. A Blocked by entry that is not a slice id goes into the body as a fourth line, `Blocked by: <entry>`, and gets no link.
- `--blocked-by` lists the issue numbers of the slice ids in Blocked by, and is left out when there are none.

Then close the issue of every `done` slice with `gh issue close <n> --reason completed`.

Add an `Issue` column to the table, after `Note`, holding `#<n>` for each slice, and write a `` **Issue:** #<parent> `` line under the plan's `**Branch:**` line. The parent stays open until `build` closes the plan.
