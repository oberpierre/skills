# Attacking a plan

A plan is a feature's slices and its decision log. Attack it on the checks below, reading the repository wherever a line asks what already exists. What follows the plan's path in the argument says which checks to run:

- **Nothing:** every check, on the whole plan.
- **`slices`:** only the slice checks, on every slice. The decisions were challenged when they were made.
- **Slice ids, such as `S2 S3`:** only the slice checks, on those slices, read against the slices around them and the decisions they carry out. Leave the rest of the plan alone.

## Decisions

- **A second mechanism.** Does it build something beside a mechanism the repository already has for the same job, instead of extending that mechanism?
- **Inferring what it could be told.** Does it guess at something a file, a configuration or the user could state, such as a value derived from naming or a format sniffed from content?
- **Malformed input.** What does it do with configuration that is missing or malformed, and with data that is? A plan silent on either is a finding.
- **Contradictions.** Does a decision contradict an ADR, the glossary, the code, or another decision in the same plan?
- **Expensive to undo.** Which decisions would cost the most to reverse once built, such as a data format, a public interface or a stored schema? Name each one whose reason the log does not give.

## Slices

- **A proof that could pass while the defect survives.** For each slice, would its acceptance test still pass if the behaviour were wrong in the way the slice exists to prevent, such as a test that checks a text was sent but not from which number? Name the assertion that is missing.
- **A gap between slices.** Does a behaviour the plan promises fall between two slices, so that each is built and tested while nothing joins them?
- **Contradictions.** Does a slice contradict a decision it carries out, or another slice?

Raise what the checks above find. Leave out how a slice will be coded where nothing in the plan depends on the answer, such as which exceptions to catch, what a log line holds or which package to add: that is settled when the slice is built, and tested there. Leave out whether an issue mirrored from the plan matches its row too, since `slice` brings the issues in step after the challenge.
