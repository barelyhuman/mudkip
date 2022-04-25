#!/usr/bin/env bash

set -euxo pipefail

curl -o mudkip.tgz -L https://github.com/barelyhuman/mudkip/releases/download/testing/linux-amd64.tgz
tar -xvzf mudkip.tgz
install linux-amd64/mudkip /usr/local/bin

mudkip