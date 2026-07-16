#!/usr/bin/env bash
# Runs the pre-commit-hooks (https://github.com/pre-commit/pre-commit-hooks)
# checks that have no file-discovery of their own -- they expect a caller
# (normally pre-commit itself) to hand them a file list, so we build one with
# git. `git grep -I -l ''` lists every tracked, non-binary file: -I skips
# binary files (matching upstream's `types: [text]`) and an empty pattern
# matches every line, so -l lists every file that "matched".
set -xueo pipefail
cd "$(git rev-parse --show-toplevel)"

TRACKED_FILES=$(git ls-files)
NONBINARY_FILES=$(git grep -Il '' -- .)
PYTHON_FILES=$(git ls-files -- '*.py' '*.pyi')
JSON_FILES=$(git ls-files -- '*.json')
YAML_FILES=$(git ls-files -- '*.yml' '*.yaml')
TOML_FILES=$(git ls-files -- '*.toml')
# check-executables-have-shebangs trusts its caller to have already filtered
# to executable files, unlike the other hooks here, so we do that ourselves.
# The `|| true` stops "no executable files" (grep exit 1) from tripping
# pipefail, which also applies inside this command substitution.
EXECUTABLE_FILES=$(git ls-files -s | { grep '^100755' || true; } | cut -f2)

echo "$TRACKED_FILES" | xargs -r check-added-large-files --enforce-all
echo "$PYTHON_FILES" | xargs -r check-ast
echo "$TRACKED_FILES" | xargs -r check-case-conflict
echo "$EXECUTABLE_FILES" | xargs -r check-executables-have-shebangs
echo "$NONBINARY_FILES" | xargs -r check-shebang-scripts-are-executable
echo "$TRACKED_FILES" | xargs -r check-merge-conflict
echo "$TRACKED_FILES" | xargs -r check-symlinks
echo "$JSON_FILES" | xargs -r check-json
echo "$YAML_FILES" | xargs -r check-yaml
echo "$TOML_FILES" | xargs -r check-toml
echo "$NONBINARY_FILES" | xargs -r detect-private-key
echo "$NONBINARY_FILES" | xargs -r mixed-line-ending --fix=no
