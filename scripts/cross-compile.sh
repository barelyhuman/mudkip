#!/usr/bin/env bash

set -euxo pipefail

build_commands=(' nimble install -y \
     ; nim c -d:release --opt:size -o:bin/linux-amd64/mudkip src/mudkip.nim && strip -s bin/linux-amd64/mudkip \
     ; nim c -d:release --opt:size --cpu:arm64 --os:linux -o:bin/linux-arm64/mudkip src/mudkip.nim && strip -s bin/linux-arm64/mudkip  \
     ; nim c -d:release --opt:size -d:mingw --cpu:i386 -o:bin/windows-386/mudkip.exe src/mudkip.nim \
     ; nim c -d:release --opt:size -d:mingw --cpu:amd64 -o:bin/windows-amd64/mudkip.exe src/mudkip.nim
 ')

 # run a docker container with osxcross and cross compile everything
 docker run -it --rm -v `pwd`:/app \
    $(docker build . -q) \
    /bin/bash -c "$build_commands"

if [ "$(uname -s)" = "Darwin" ]
then 
    nimble release_amd
    nimble release_arm
fi

# create archives

cd bin
for dir in $(ls -d *);
do 
    tar cfzv "$dir".tgz $dir
    rm -rf $dir
done
cd ..