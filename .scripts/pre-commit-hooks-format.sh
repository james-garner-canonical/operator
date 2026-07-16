#!/usr/bin/env bash
# Runs the pre-commit-hooks (https://github.com/pre-commit/pre-commit-hooks)
# fixers. See pre-commit-hooks-lint.sh for why git is used to build the file
# lists these tools need.
set -xueo pipefail
cd "$(git rev-parse --show-toplevel)"

NONBINARY_FILES=$(git grep -Il '' -- .)
# end-of-file-fixer and trailing-whitespace-fixer exclude this file, unlike
# mixed-line-ending below.
TRIMMABLE_FILES=$(git grep -Il '' -- . ':!docs/reuse/best-practices.txt')

echo "$TRIMMABLE_FILES" | xargs -r end-of-file-fixer
echo "$TRIMMABLE_FILES" | xargs -r trailing-whitespace-fixer
echo "$NONBINARY_FILES" | xargs -r mixed-line-ending
