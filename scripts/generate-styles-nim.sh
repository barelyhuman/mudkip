#! /usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/.."

echo $PROJECT_DIR
npm i -g @parcel/css-cli
cd "$PROJECT_DIR/static"
echo "$(pwd)"

MINIFIED_OUTPUT=`npx parcel-css --targets '>= 0.25%' --minify default-styles.css`

cd "$PROJECT_DIR"

cat > src/styles.nim << EOF
proc defaultStyles*():string =
    ## GENERATED CODE
    ## This file is generated using the generate-styles-nim.sh file with styles 
    ## from the original static/default-styles.css
    return r"""$MINIFIED_OUTPUT"""
EOF

