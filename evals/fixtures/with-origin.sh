#!/usr/bin/env bash
# Gives the repository in the current directory a bare origin inside the
# workspace, which the eval sandbox can reach, with main pushed and origin/HEAD
# set, as a clone would leave it.
set -euo pipefail
# The default branch is main whatever init.defaultBranch says, so cases can name it.
[[ "$(git branch --show-current)" == main ]] || git branch -m main
git init -q --bare .eval-origin.git
echo ".eval-origin.git/" >> .git/info/exclude
git remote add origin "$(pwd)/.eval-origin.git"
git push -q origin main
git remote set-head origin main
