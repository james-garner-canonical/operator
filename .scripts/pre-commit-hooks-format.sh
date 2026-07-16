#!/usr/bin/env bash
set -xueo pipefail
cd "$(git rev-parse --show-toplevel)"
NONBINARY_FILES=$(git grep -Il '' -- .)

set -x  # Print commands as they are executed.
xargs -r end-of-file-fixer <<< "$NONBINARY_FILES"
xargs -r mixed-line-ending <<< "$NONBINARY_FILES"
xargs -r trailing-whitespace-fixer <<< "$NONBINARY_FILES"
