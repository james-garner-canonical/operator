#!/usr/bin/env bash
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
xargs check-added-large-files --enforce-all <<< "$TRACKED_FILES"
xargs check-case-conflict <<< "$TRACKED_FILES"
xargs check-merge-conflict <<< "$TRACKED_FILES"
xargs check-symlinks <<< "$TRACKED_FILES"
xargs check-executables-have-shebangs <<< "$EXECUTABLE_FILES"
xargs check-shebang-scripts-are-executable <<< "$NONBINARY_FILES"
xargs detect-private-key <<< "$NONBINARY_FILES"
xargs mixed-line-ending --fix=no <<< "$NONBINARY_FILES"
xargs check-json <<< "$JSON_FILES"
xargs check-ast <<< "$PYTHON_FILES"
xargs check-toml <<< "$TOML_FILES"
xargs check-yaml <<< "$YAML_FILES"
