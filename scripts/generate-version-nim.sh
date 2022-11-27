#! /usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/.."

cd "$PROJECT_DIR"

MINIFIED_OUTPUT=$(cat .commitlog.release)

cat > src/utils/version.nim << EOF
proc currentVersion*():string =
    ## GENERATED CODE
    ## This file is generated using the generate-version-nim.sh
    return r"""$MINIFIED_OUTPUT"""
EOF

