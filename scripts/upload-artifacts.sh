#!/usr/bin/env bash

set -euxo pipefail

source .env

CURRENT_VERSION=`cat .commitlog.release`

get_release_from_tag() {
  curl --silent "https://api.github.com/repos/barelyhuman/mudkip/releases/tags/$1" | jq -r .id
}

RELEASE_ID=$(get_release_from_tag "$CURRENT_VERSION")

cd bin
for file in $(ls *.tgz);
do 
    curl \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: $(file -b --mime-type $file)" \
    --data-binary @$file \
    "https://uploads.github.com/repos/barelyhuman/mudkip/releases/$RELEASE_ID/assets?name=$file"
done
cd ..
