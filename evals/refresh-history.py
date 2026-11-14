"""Keep the skill text recorded in each eval history equal to the current SKILL.md.

A resumed session replays the skill text expanded when it was recorded, so after
an edit to SKILL.md a stale history tests the old instructions.

Usage: refresh-history.py [--check] [history.jsonl ...]   (default: every history)
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MARKER = "Base directory for this skill:"


def expansion(skill_md: Path, args: str, head: str) -> str:
    body = skill_md.read_text().split("---", 2)[2].lstrip("\n")
    return f"{head}\n\n{body.replace('$ARGUMENTS', args)}"


def refresh(history: Path, write: bool) -> bool:
    """Return whether the history was already current."""
    entries = [json.loads(line) for line in history.read_text().splitlines() if line.strip()]
    args = ""
    current = True
    for entry in entries:
        content = entry.get("message", {}).get("content") if entry.get("type") == "user" else None
        if isinstance(content, str) and "<command-args>" in content:
            args = content.split("<command-args>")[1].split("</command-args>")[0]
        if not isinstance(content, list):
            continue
        for block in content:
            text = block.get("text", "")
            if block.get("type") != "text" or not text.startswith(MARKER):
                continue
            head = text.split("\n", 1)[0]
            skill_md = ROOT / "skills" / Path(head[len(MARKER):].strip()).name / "SKILL.md"
            wanted = expansion(skill_md, args, head)
            if text != wanted:
                current = False
                block["text"] = wanted
    if write and not current:
        history.write_text("".join(json.dumps(e, ensure_ascii=False) + "\n" for e in entries))
    return current


def main(argv: list[str]) -> int:
    check = "--check" in argv
    paths = [Path(a) for a in argv if a != "--check"] or sorted(ROOT.glob("evals/*/history.jsonl"))
    stale = [p for p in paths if not refresh(p, write=not check)]
    for p in stale:
        verb = "is stale; run evals/refresh-history.py" if check else "refreshed"
        print(f"{p.relative_to(ROOT)} {verb}", file=sys.stderr)
    return 1 if check and stale else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
