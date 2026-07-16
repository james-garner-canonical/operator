#!/usr/bin/env bash
# Runs the pre-commit-hooks (https://github.com/pre-commit/pre-commit-hooks)
# fixers. See pre-commit-hooks-lint.sh for why git is used to build the file
# lists these tools need.
set -xueo pipefail
cd "$(git rev-parse --show-toplevel)"

NONBINARY_FILES=$(git grep -Il '' -- .)

echo "$NONBINARY_FILES" | xargs -r end-of-file-fixer
echo "$NONBINARY_FILES" | xargs -r trailing-whitespace-fixer
echo "$NONBINARY_FILES" | xargs -r mixed-line-ending
