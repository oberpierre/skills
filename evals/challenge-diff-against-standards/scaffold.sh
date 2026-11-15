#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/base"/. .
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Record the notifier standards"
cp -R "$here/change"/. .
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Send shipping notices by SMS"
