#!/usr/bin/env bash
# Builds the notifier fixture as a committed repository in the current directory.
set -euo pipefail
fixture="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/notifier"
cp -R "$fixture"/. .
git init -q
git add -A
git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Initial commit"
echo "scaffolded $(pwd)"
