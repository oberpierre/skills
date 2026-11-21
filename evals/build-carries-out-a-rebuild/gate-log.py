# Eval only: inside a rebase, log the subject of the commit being rewritten.
import os as _os
import subprocess as _sp

if _os.path.isdir(root / ".git" / "rebase-merge"):
    _subject = _sp.run(["git", "log", "-1", "--format=%s"], cwd=root,
                       capture_output=True, text=True).stdout.strip()
    with open(root / ".eval-rebase.log", "a") as _f:
        _f.write(f"rebase:{_subject}\n")
