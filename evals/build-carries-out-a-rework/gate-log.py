# Eval only: inside a rebase, log the subject of the commit being rewritten, whether its own
# tree holds both slices' behaviour, whether its parent holds neither, and what its committed
# plan says of the S1 and S2 rows.
import os as _os
import subprocess as _sp

if _os.path.isdir(root / ".git" / "rebase-merge"):
    def _show(_ref):
        return _sp.run(["git", "show", _ref], cwd=root, capture_output=True, text=True).stdout

    _subject = _sp.run(["git", "log", "-1", "--format=%s"], cwd=root,
                       capture_output=True, text=True).stdout.strip()
    _both = ("tracking_url" in (root / "notify" / "shipping.py").read_text()
             and "sender" in (root / "notify" / "email.py").read_text())
    _alone = "tracking_url" not in _show("HEAD~1:notify/shipping.py")
    _plan = _show("HEAD:docs/work/shipping-notes/plan.md")
    _s1 = [_l for _l in _plan.splitlines() if _l.startswith("| S1 ")]
    _s1done = bool(_s1) and "| done | |" in _s1[0]
    _sender = bool(_s1) and "sender" in _s1[0].lower()
    _s2gone = not any(_l.startswith("| S2 ") for _l in _plan.splitlines())
    with open(root / ".eval-rebase.log", "a") as _f:
        _f.write(f"rebase:{_subject}|{'both' if _both else 'one'}|{'alone' if _alone else 'stacked'}"
                 f"|{'s1done' if _s1done else 's1open'}|{'sender' if _sender else 'nosender'}"
                 f"|{'s2gone' if _s2gone else 's2kept'}\n")
