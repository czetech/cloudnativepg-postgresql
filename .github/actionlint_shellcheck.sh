#!/usr/bin/env sh
set -e

# ShellCheck wrapper for actionlint

exec shellcheck --format=json "--shell=$6" --external-sources -
