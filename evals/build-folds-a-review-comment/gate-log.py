# Eval only: inside a rebase, log the subject of the commit being rewritten and
# whether that commit's own tree already has the full stop.
import os as _os
import subprocess as _sp

if _os.path.isdir(root / ".git" / "rebase-merge"):
    _subject = _sp.run(["git", "log", "-1", "--format=%s"], cwd=root,
                       capture_output=True, text=True).stdout.strip()
    _fixed = "{tracking_url}." in (root / "notify" / "shipping.py").read_text()
    with open(root / ".eval-rebase.log", "a") as _f:
        _f.write(f"rebase:{_subject}|{'fixed' if _fixed else 'unfixed'}\n")
