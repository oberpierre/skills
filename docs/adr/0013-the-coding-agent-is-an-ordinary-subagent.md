# The coding agent is an ordinary subagent

`build` starts each slice's coding agent as a general-purpose subagent with the Agent tool, and hands it pointers only: the path of `SLICE.md` in `build`'s folder, the plan, the slice id, the commit it starts from, the gate and the commit style. The plugin ships no `agents/` folder for it, and no extra skill appears in the `/` menu. The agent runs on the model `build_model` in `.agents/config.yml` names, `sonnet` when the key is missing. `build` itself has no `model:` line and runs on the session's model.

## Why

A plugin agent definition would be a second kind of component to ship and keep in step with `build`, and a skill for the coding work would show up in the `/` menu as something to invoke by hand. A sibling file that `build` points at stays private to `build`, as ADR 0008 has a skill own its material.

Coding is the easier part of the work once `grill` and `slice` have made every decision, so a cheaper model suits it, and `SLICE.md` relies on nothing specific to one model, so a stronger one can be configured. `build`'s own judgement calls go to the user as rounds, and a skill cannot take its model from config, so it follows the session.
