#!/usr/bin/env bash

set -euxo pipefail

CURRENT_VERSION=`cat .commitlog.release`
CHANGELOG=$(commitlog --promo | sed -n -e 'H;${x;s/\n/\\n/g;s/^,//;p;}')

source .env

curl -v -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type:application/json" \
  "https://api.github.com/repos/barelyhuman/mudkip/releases" \
  -d '{"tag_name": "'"$CURRENT_VERSION"'","target_commitish": "main","name": "'"$CURRENT_VERSION"'","body": "'"$CHANGELOG"'","draft": true,"prerelease": false}'
