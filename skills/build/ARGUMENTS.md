# Reading the argument

The argument is `[plan] [S<n> [comment] | close]`, or `close [plan]`. Read it left to right.

1. The first word is the plan when it is a path or names a folder under `docs/work/`. It is never a plan when it is `close` or a slice id, even where a folder has that name. Take it off.
2. When the first word is `close`, the word after it is the plan when it is a path or names a folder under `docs/work/`. Take both off, and remember that the command is `close`.
3. When the first word is neither a plan, `close` nor a slice id, stop and build, list and close nothing. Name the word you could not read and the plans you found under `docs/work/`.
4. When no plan was named, the plan is the only one under `docs/work/`. When there are several or none, ask which plan and stop, before anything is built or closed, and name each plan you found. Plain `/build`, with nothing else, is the one exception: with several plans it lists every plan, as `LIST.md` says, and asks nothing.
5. What is left decides the command:
   - nothing, after a named plan: build every remaining slice, as `FEATURE.md` says;
   - nothing, with no plan named: list the slices, as `LIST.md` says;
   - `close`, whether it came first or right after the plan: the close command, as `CLOSE.md` says;
   - `S<n>`: build that slice of the plan, and every word after it is a review comment, so `S2 close the loop` is a comment on S2.

Everything the other files say about "the plan" is the plan this rule resolved, and a plan that was named leaves every other plan untouched.
