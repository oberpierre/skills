# Listing the slices

Plain `/build` changes nothing. Read only the plan, which is the only plan under `docs/work/`, and when there are several or none, ask which plan and stop. Read no config, create no branch, start no agent and commit nothing.

List every row of the slices table, in the table's order, one line each: the slice id, its status as `todo`, `done` or `rework`, and the behaviour's first clause.

Then suggest the next slice: the first row, in the table's order, that is `todo` or `rework` and whose `Blocked by` is `none` or names only `done` slices, so `none` counts as unblocked. Say it as `/build S<n>`, and name no other slice as a command. When every row left is blocked, name those rows and the unfinished slice each waits for. When every row is `done`, suggest `/build close`.
