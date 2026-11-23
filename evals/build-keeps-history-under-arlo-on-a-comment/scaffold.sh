#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../build-folds-a-review-comment/scaffold.sh"
sed -i 's/^commit_style: .*/commit_style: arlo/' .agents/config.yml
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Use arlo"
