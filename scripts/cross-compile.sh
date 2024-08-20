#!/usr/bin/env bash

set -euxo pipefail

nimxc c --target linux-amd64 --outdir:./bin/linux-amd64 src/mudkip.nim
nimxc c --target macosx-amd64 --outdir:./bin/macosx-amd64 src/mudkip.nim
nimxc c --target macosx-arm64 --outdir:./bin/macosx-arm64 src/mudkip.nim
nimxc c --target windows-amd64 --outdir:./bin/windows-amd64 src/mudkip.nim
nimxc c --target windows-arm64 --outdir:./bin/windows-arm64 src/mudkip.nim
nimxc c --target windows-i386 --outdir:./bin/windows-i386 src/mudkip.nim

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