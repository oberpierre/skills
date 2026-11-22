#!/usr/bin/env bash
# Installs a post-commit hook in the repository in the current directory. After each commit it
# appends one line to .eval-commits.log: the files the commit holds, then `done:S<n>` for each slice
# row the commit sets to done in a plan, so a grader can read the committed history instead of the
# working tree. An optional argument names the log, for a case that already writes .eval-commits.log.
set -euo pipefail
log="${1:-.eval-commits.log}"
printf '%s\n' "$log" >> .git/info/exclude
cat > .git/hooks/post-commit <<'HOOK'
#!/bin/sh
top="$(git rev-parse --show-toplevel)"
files="$(git diff-tree --root --no-commit-id --name-only -r HEAD | tr '\n' ' ')"
rows="$(git show --format= -p HEAD -- 'docs/work/*/plan.md' | sed -n 's/^+| *\(S[0-9]*\) .*| *done *|.*/ done:\1/p' | tr -d '\n')"
echo "${files% }$rows" >> "$top/LOG"
HOOK
sed -i "s#/LOG\"#/$log\"#" .git/hooks/post-commit
chmod +x .git/hooks/post-commit
