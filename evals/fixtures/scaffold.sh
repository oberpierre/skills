#!/usr/bin/env bash
# Builds the named fixture as a committed repository in the current directory.
# Usage: scaffold.sh <fixture folder under evals/fixtures>
set -euo pipefail
fixture="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$1"
cp -R "$fixture"/. .
git init -q
git add -A
git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Initial commit"
echo "scaffolded $1 in $(pwd)"
