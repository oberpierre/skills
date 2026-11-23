#!/usr/bin/env bash
# Installs post-merge and post-commit hooks in the repository in the current directory. After each
# merge commit, made by `git merge` or by `git commit` after `--no-commit`, they write
# .eval-merge.log: the parent count, the branch, the files the merged tree holds, the second
# parent's subject and the message. It also appends a `merged` line to gh-calls.log, so a grader
# can tell whether a gh call came before or after the merge.
set -euo pipefail
printf '.eval-merge.log\n' >> .git/info/exclude
cat > .git/hooks/post-merge <<HOOK
#!/bin/sh
top="\$(git rev-parse --show-toplevel)"
[ "\$(git rev-list --parents -1 HEAD | wc -w)" -gt 2 ] || exit 0
{
  echo "parents: \$(( \$(git rev-list --parents -1 HEAD | wc -w) - 1 ))"
  echo "branch: \$(git branch --show-current)"
  git ls-tree -r --name-only HEAD | sed 's/^/tree: /'
  echo "second-parent: \$(git log -1 --format=%s HEAD^2)"
  git log -1 --format=%B
} >> "\$top/.eval-merge.log"
echo merged >> "\$top/gh-calls.log"
HOOK
cp .git/hooks/post-merge .git/hooks/post-commit
chmod +x .git/hooks/post-merge .git/hooks/post-commit
