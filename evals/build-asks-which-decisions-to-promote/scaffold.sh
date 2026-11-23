#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../fixtures/plan-on-branch.sh" "$here/plan.md" github
