#!/usr/bin/env bash
set -ueo pipefail
cd "$(git rev-parse --show-toplevel)"

NONBINARY_FILES=$(git grep -Il '' -- .)

set -x  # Print commands as they are executed.
xargs end-of-file-fixer <<< "$NONBINARY_FILES"
xargs mixed-line-ending <<< "$NONBINARY_FILES"
xargs trailing-whitespace-fixer <<< "$NONBINARY_FILES"
