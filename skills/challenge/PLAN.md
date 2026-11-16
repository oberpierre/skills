# Attacking a plan

A plan is a feature's slices and its decision log. Attack it on each of these, reading the repository wherever a line asks what already exists.

- **A second mechanism.** Does it build something beside a mechanism the repository already has for the same job, instead of extending that mechanism?
- **Inferring what it could be told.** Does it guess at something a file, a configuration or the user could state, such as a value derived from naming or a format sniffed from content?
- **Malformed input.** What does it do with configuration that is missing or malformed, and with data that is? A plan silent on either is a finding.
- **Contradictions.** Does a slice or a decision contradict an ADR, the glossary, the code, or another decision in the same plan?
- **Expensive to undo.** Which decisions would cost the most to reverse once built, such as a data format, a public interface or a stored schema? Name each one whose reason the log does not give.


Raise what the checks above find. Leave out how a slice will be coded where nothing in the plan depends on the answer, such as which exceptions to catch, what a log line holds or which package to add: that is settled when the slice is built, and tested there.
