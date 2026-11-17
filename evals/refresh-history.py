"""Keep the skill text recorded in each eval history equal to the current SKILL.md.

A resumed session replays the skill text expanded when it was recorded, so after
an edit to SKILL.md a stale history tests the old instructions. The same holds for
a recorded Read of any other file under skills/, such as a skill's reference file.

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


def numbered(path: Path) -> str:
    """Return a file's text as a recorded Read result shows it, each line after its number and a tab."""
    lines = path.read_text().split("\n")
    return "\n".join(f"{i}\t{line}" for i, line in enumerate(lines, 1))


def relink(entries: list[dict]) -> bool:
    """Point each entry whose parent is missing at the entry before it, and return whether all were linked.

    A resume walks parentUuid back from the last entry and silently stops at a
    missing parent, so removing an entry from a recording drops everything before it.
    """
    seen: set[str] = set()
    previous = None
    linked = True
    for entry in entries:
        parent = entry.get("parentUuid")
        if parent is not None and parent not in seen:
            entry["parentUuid"] = previous
            linked = False
        seen.add(entry["uuid"])
        previous = entry["uuid"]
    return linked


def refresh(history: Path, write: bool) -> bool:
    """Return whether the history was already current."""
    entries = [json.loads(line) for line in history.read_text().splitlines() if line.strip()]
    args = ""
    reads: dict[str, Path] = {}
    current = relink(entries)
    for entry in entries:
        content = entry.get("message", {}).get("content")
        if entry.get("type") == "assistant" and isinstance(content, list):
            for block in content:
                if block.get("type") != "tool_use":
                    continue
                if block.get("name") == "Skill":
                    # A skill called as a tool expands with that call's args, not the command's.
                    args = block.get("input", {}).get("args", "")
                path = Path(block.get("input", {}).get("file_path", ""))
                if block.get("name") == "Read" and path.is_relative_to(ROOT / "skills") and path.is_file():
                    reads[block["id"]] = path
            continue
        if entry.get("type") != "user":
            continue
        if isinstance(content, str) and "<command-args>" in content:
            args = content.split("<command-args>")[1].split("</command-args>")[0]
        if not isinstance(content, list):
            continue
        for block in content:
            if block.get("type") == "tool_result" and block.get("tool_use_id") in reads:
                wanted = numbered(reads[block["tool_use_id"]])
                if block.get("content") != wanted:
                    current = False
                    block["content"] = wanted
                    entry.pop("toolUseResult", None)
                continue
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
    paths = [Path(a).resolve() for a in argv if a != "--check"] or sorted(ROOT.glob("evals/*/history.jsonl"))
    stale = [p for p in paths if not refresh(p, write=not check)]
    for p in stale:
        verb = "is stale or its chain is broken; run evals/refresh-history.py" if check else "refreshed"
        print(f"{p.relative_to(ROOT)} {verb}", file=sys.stderr)
    return 1 if check and stale else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
