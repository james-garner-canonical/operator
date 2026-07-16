#!/usr/bin/env bash
# Runs the pre-commit-hooks (https://github.com/pre-commit/pre-commit-hooks)
# checks that have no file-discovery of their own -- they expect a caller
# (normally pre-commit itself) to hand them a file list, so we build one with
# git. `git grep -I -l ''` lists every tracked, non-binary file: -I skips
# binary files (matching upstream's `types: [text]`) and an empty pattern
# matches every line, so -l lists every file that "matched".
set -ueo pipefail
cd "$(git rev-parse --show-toplevel)"
TRACKED_FILES=$(git ls-files)
EXECUTABLE_FILES=$(git ls-files -s | grep '^100755' | cut -f2)
NONBINARY_FILES=$(git grep -Il '' -- .)
JSON_FILES=$(git ls-files -- '*.json')
PYTHON_FILES=$(git ls-files -- '*.py' '*.pyi')
TOML_FILES=$(git ls-files -- '*.toml')
YAML_FILES=$(git ls-files -- '*.yml' '*.yaml')

set -x  # Print commands as they are executed.
xargs -r check-added-large-files --enforce-all <<< "$TRACKED_FILES"
xargs -r check-case-conflict <<< "$TRACKED_FILES"
xargs -r check-merge-conflict <<< "$TRACKED_FILES"
xargs -r check-symlinks <<< "$TRACKED_FILES"
xargs -r check-executables-have-shebangs <<< "$EXECUTABLE_FILES"
xargs -r check-shebang-scripts-are-executable <<< "$NONBINARY_FILES"
xargs -r detect-private-key <<< "$NONBINARY_FILES"
xargs -r mixed-line-ending --fix=no <<< "$NONBINARY_FILES"
xargs -r check-json <<< "$JSON_FILES"
xargs -r check-ast <<< "$PYTHON_FILES"
xargs -r check-toml <<< "$TOML_FILES"
xargs -r check-yaml <<< "$YAML_FILES"
