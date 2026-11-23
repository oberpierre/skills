# Listing the slices

Plain `/build` changes nothing. Read only the plans, which are the plan `ARGUMENTS.md` resolved or, when several exist and none was named, every plan under `docs/work/`. Read no config, create no branch, start no agent and commit nothing. With several plans, group the listing by plan, naming each, and ask no question.

List every row of a plan's slices table, in the table's order, one line each: the slice id, its status as `todo`, `done` or `rework`, and the behaviour's first clause.

Check each table against the rules that `SKILL.md` sets under "Before building": a missing column, a status other than `todo`, `done` or `rework`, an id used twice, a `Blocked by` that names a slice that is not in the table, a `rework` row with an empty note. When a table breaks one, list the rows you can read, name each problem, and suggest no slice from that plan. Repair nothing.

Otherwise suggest the next slice of each plan: the first row, in the table's order, that is `todo` or `rework` and whose `Blocked by` is `none` or names only `done` slices, so `none` counts as unblocked. Say it as `/build S<n>`, or as `/build <plan> S<n>` when there are several plans, since `/build S<n>` then asks which plan. Name no other slice as a command. When every row left is blocked, name those rows and the unfinished slice each waits for. When every row is `done`, suggest `/build close`, or `/build <plan> close` with several plans.
