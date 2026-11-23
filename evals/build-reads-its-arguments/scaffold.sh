#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/scaffold.sh" notifier
cp -R "$here/../fixtures/gated/." .
sed -i 's#^commit_style: .*#commit_style: docs/commit-style.md#' .agents/config.yml
mkdir -p docs
cat > docs/commit-style.md <<'STYLE'
extends: conventional

# This repository's commit style

Every subject ends with the ticket ` [TRACK-7]`.
STYLE
git add -A && git -c user.name=eval -c user.email=eval@example.invalid commit -q -m "Add the gate"
"$here/../fixtures/with-origin.sh"
"$here/../fixtures/log-commits.sh"
mkdir -p docs/work/shipping-notes docs/work/tracking
cp "$here/plan.md" docs/work/shipping-notes/plan.md
# A second plan with the same slices: building from it, or touching it, shows in its own table.
sed -e 's/shipping-notes/tracking/g' "$here/plan.md" > docs/work/tracking/plan.md
