#!/usr/bin/env bash

set -euxo pipefail

build_commands=('
    choosenim 1.6.4 \
    ; nimble install -y \
    ; nim c -d:release --opt:size -o:bin/linux-amd64/mudkip src/mudkip.nim && strip -s bin/linux-amd64/mudkip \
    ; nim c -d:release --opt:size --cpu:arm64 --os:linux -o:bin/linux-arm64/mudkip src/mudkip.nim && strip -s bin/linux-arm64/mudkip  \
    ; nim c -d:release --opt:size -d:mingw --cpu:i386 -o:bin/windows-386/mudkip.exe src/mudkip.nim && strip -s bin/windows-386/mudkip.exe \
    ; nim c -d:release --opt:size -d:mingw --cpu:amd64 -o:bin/windows-amd64/mudkip.exe src/mudkip.nim && strip -s bin/windows-amd64/mudkip.exe
')

# run a docker container with osxcross and cross compile everything
docker run -it --rm -v `pwd`:/usr/local/src \
   chrishellerappsian/docker-nim-cross:latest \
   /bin/bash -c "choosenim stable; $build_commands"


if [ "$(uname -s)" = "Darwin" ]
then 
    nim c -d:release --os:macosx --cpu:amd64 -o:bin/darwin-amd64/mudkip src/mudkip.nim; strip bin/darwin-amd64/mudkip 
    nim c -d:release --os:macosx --cpu:arm64 -o:bin/darwin-arm64/mudkip src/mudkip.nim; strip bin/darwin-arm64/mudkip  
fi

# create archives

cd bin
for dir in $(ls -d *);
do 
    tar cfzv "$dir".tgz $dir
    rm -rf $dir
done
cd ..