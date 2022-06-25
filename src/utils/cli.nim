import "std/os"
import "std/times"

import "./version"

const RED = "31"
const GREEN = "32"
const CYAN = "36"
const RESET = "0"

## This module consists of isolated helper functions
## for the cli side of things for mudkip

proc writeVersion*() =
  echo getAppFilename().extractFilename() & " " & currentVersion()

proc writeHelp*() =
  writeVersion()
  echo """

  -h, --help        : show help
  -v, --version     : show version
  -p, --poll        : poll every few seconds for changes
  -i, --in          : folder to convert (contains markdown files) (default: docs)
  -o, --out         : folder to place the converted files (default: dist)
  --stylesheet      : custom stylesheet
  --baseurl         : use a different base url (default: / )
  """
  quit()


proc getCurrentTimeStamp*(): string =
  return "[" & getTime().format("HH:mm:ss") & "] "

proc toAnsi(color: string, bold: bool = false): string =
  if bold:
    return "\e[1;"&color&"m"
  return "\e["&color&"m"

proc info*[T](msg: T): string =
  return toAnsi(CYAN, true) & msg & toAnsi(RESET)

proc success*[T](msg: T): string =
  return toAnsi(GREEN, true) & msg & toAnsi(RESET)

proc error*[T](msg: T): string =
  return toAnsi(RED) & msg & toAnsi(RESET)
