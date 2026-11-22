# Eval only: log the state of each slice row in the plan as it is staged, or as it is committed
# during a rebase, where the index equals HEAD. A row is its status, "+note" when its Note is not
# empty, or "gone" when the row is missing. Status and Note are the fifth and sixth columns, an
# Issue column coming after them.
import re as _re2
import subprocess as _sp2

_plan2 = _sp2.run(["git", "show", ":docs/work/shipping-notes/plan.md"], cwd=root,
                  capture_output=True, text=True).stdout
_rows = {}
for _line in _plan2.splitlines():
    _m2 = _re2.match(r"\| *(S\d+) *\|", _line)
    if _m2:
        _cells = [_c.strip() for _c in _line.strip().strip("|").split("|")]
        _rows[_m2.group(1)] = _cells[4] + ("" if _cells[5] == "" else "+note")
with open(root / ".eval-head.log", "a") as _f2:
    _f2.write("head:" + " ".join(f"{_k}:{_rows.get(_k, 'gone')}" for _k in ("S1", "S2", "S3")) + "\n")
