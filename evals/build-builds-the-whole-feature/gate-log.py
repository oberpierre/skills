# Eval only: with a commit staged, log each slice row it sets to done.
import re as _re
import subprocess as _sp

if _sp.run(["git", "diff", "--cached", "--quiet"], cwd=root).returncode:
    _diff = _sp.run(["git", "diff", "--cached", "--", "docs/work/shipping-notes/plan.md"],
                    cwd=root, capture_output=True, text=True).stdout
    with open(root / ".eval-commits.log", "a") as _f:
        for _m in _re.finditer(r"^\+\| *(S\d) .*\| *done *\|", _diff, _re.M):
            _f.write(_m.group(1) + "\n")
