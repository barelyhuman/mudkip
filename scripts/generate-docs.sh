#!/usr/bin/env bash

mkdir -p docs 
curl -o mudkip.tgz -L https://github.com/barelyhuman/mudkip/releases/latest/download/linux-amd64.tgz
tar -xvzf mudkip.tgz
install linux-amd64/mudkip /usr/local/bin

# hack for github pages till mudkip doesn't add baseURL functionality
sed -i s#\]\(/#\]\(/mudkip/#g ./docs/_sidebar.md

mudkip 


