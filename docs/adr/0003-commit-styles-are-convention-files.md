# Commit styles are convention files

`commit_style` in `.agents/config.yml` names either a preset shipped with these skills or a path to a Markdown file in the repository. The file states, in prose, how a commit message is written: its format, its markers, any ticket reference, and whether a correction becomes a fixup or a commit of its own. `setup` proposes a style by reading the repository's history, and asks when there is none.

The presets are `arlo`, `arlo-features`, `conventional` and `plain`. A style may begin with `extends: <style>` and then state only what it changes. Extension is one level deep, so a style never extends a style that itself extends another.

`arlo` is a condensed version of Arlo's Commit Notation, written for an agent to apply and linking to its source. `arlo-features` extends it for feature development. Its `^` is earned by one behaviour pinned by a test with the gate green, whatever the line count. A correction that records a discovery stays as its own commit, whereas a correction of a review finding becomes a fixup and is squashed into the commit it corrects. `t` marks a commit that changes only tests, either pinning behaviour that already exists or repairing a test found after it reached the main branch. The agent that ran the gate sets the risk marker, and it writes `!` whenever something could not be verified.

## Why

A commit convention is mostly rules (what earns a marker, when a fix stays visible) rather than a shape, and a template string can express a shape only. Prose is what an agent reads anyway, and one more sentence in a file covers a case such as a ticket number at the end of the subject without a template language to design and document.

A style is never a URL. Fetching one at commit time would make every commit depend on the network and on content that can change without notice, and it would have the agent follow instructions from a page nobody reviewed.

Extension is limited to one level because a reader should learn a style from at most two files.
