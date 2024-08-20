# Package

version       = "0.1.6"
author        = "Reaper"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["mudkip"]


# Dependencies

requires "nim >= 1.6.4"
requires "markdown >= 0.8.5"
requires "jsony >= 1.1.3"


task release_amd, "Build a production release (macOS)":
  --verbose
  --forceBuild:on
  --cc:clang
  --define:release
  --deepcopy:on
  --cpu:arm64
  --passC:"-flto -target x86_64-apple-macos10.12" 
  --passL:"-flto -target x86_64-apple-macos10.12"
  --hints:off
  --outdir:"bin/darwin-amd64"
  setCommand "c", "src/mudkip.nim"

task release_arm, "Build a production release (macOS)":
  --verbose
  --forceBuild:on
  --cc:clang
  --define:release
  --deepcopy:on
  --cpu:arm64
  --passC:"-flto -target arm64-apple-macos11" 
  --passL:"-flto -target arm64-apple-macos11"
  --hints:off
  --outdir:"bin/darwin-arm64"
  setCommand "c", "src/mudkip.nim"