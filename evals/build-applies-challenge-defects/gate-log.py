
# Eval only: with a commit staged, log whether it sets S1 to done.
import re as _re
import subprocess as _sp

if _sp.run(["git", "diff", "--cached", "--quiet"], cwd=root).returncode:
    _diff = _sp.run(["git", "diff", "--cached", "--", "docs/work/tracking/plan.md"],
                    cwd=root, capture_output=True, text=True).stdout
    _done = _re.search(r"^\+\| *S1 .*\| *done *\|", _diff, _re.M)
    with open(root / ".eval-commits.log", "a") as _f:
        _f.write(("done" if _done else "other") + "\n")
