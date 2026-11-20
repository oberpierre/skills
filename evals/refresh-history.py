"""Keep the skill text recorded in each eval history equal to the current SKILL.md.

A resumed session replays the skill text expanded when it was recorded, so after
an edit to SKILL.md a stale history tests the old instructions. The same holds for
a recorded Read of any other file under skills/, such as a skill's reference file.

Usage: refresh-history.py [--check] [history.jsonl ...]   (default: every history)
"""

import json
import re
import subprocess
import sys
from functools import cache
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


def skill_file(recorded: str) -> Path | None:
    """Map a recorded path to this checkout's file under skills/, wherever the recording's checkout was.

    A path that names a skill of this repository but no longer exists fails, so a
    renamed or deleted file cannot leave its old text replayed unnoticed.
    """
    parts = Path(recorded).parts
    for i in range(len(parts) - 2, -1, -1):
        if parts[i] == "skills" and (ROOT / "skills" / parts[i + 1]).is_dir():
            path = ROOT.joinpath("skills", *parts[i + 1:])
            if not path.is_file():
                sys.exit(f"refresh-history.py: a recording reads {recorded}, and {path.relative_to(ROOT)} does not exist")
            return path
    return None


@cache
def past_versions(path: Path) -> tuple[str, ...]:
    """Return every committed text of a file, newest first."""
    rel = path.relative_to(ROOT).as_posix()
    commits = subprocess.run(["git", "-C", str(ROOT), "rev-list", "HEAD", "--", rel],
                             capture_output=True, text=True, check=True).stdout.split()
    texts = []
    for commit in commits:
        shown = subprocess.run(["git", "-C", str(ROOT), "show", f"{commit}:{rel}"], capture_output=True, text=True)
        if shown.returncode == 0 and shown.stdout not in texts:
            texts.append(shown.stdout)
    return tuple(texts)


def refresh_output(text: str, path: Path) -> str | None:
    """Replace a skill file's old text in a recorded command's output with its current text.

    Return None when the output holds neither the current text nor any committed one.
    """
    current = path.read_text()
    if current in text:
        return text
    for old in past_versions(path):
        if old and old in text:
            return text.replace(old, current)
    return None


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
    cats: dict[str, list[Path]] = {}
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
                if block.get("name") == "Read":
                    path = skill_file(block.get("input", {}).get("file_path", ""))
                    if path:
                        reads[block["id"]] = path
                if block.get("name") == "Bash":
                    # A recorded `cat` of a skill file replays its old text just as a Read does.
                    command = block.get("input", {}).get("command", "")
                    found = [skill_file(p) for p in re.findall(r"\bcat\s+(\S*skills/\S+)", command)]
                    if any(found):
                        cats[block["id"]] = [p for p in found if p]
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
            if block.get("type") == "tool_result" and block.get("tool_use_id") in cats:
                text = block.get("content")
                if not isinstance(text, str):
                    sys.exit(f"refresh-history.py: {history.relative_to(ROOT)} has a recorded cat of a skill file whose output is not text")
                for path in cats[block["tool_use_id"]]:
                    fresh = refresh_output(text, path)
                    if fresh is None:
                        sys.exit(f"refresh-history.py: {history.relative_to(ROOT)} has a recorded cat of "
                                 f"{path.relative_to(ROOT)} holding no committed version of it; re-record that turn")
                    text = fresh
                if text != block["content"]:
                    current = False
                    block["content"] = text
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
