#!/usr/bin/env bash
set -euo pipefail
here="$(dirname "$0")"
"$here/../build-folds-a-review-comment/scaffold.sh"
git push -q origin feature/shipping-notes:main
