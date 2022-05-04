import parseopt
import "std/os"
import "markdown"
import "std/locks"
import "std/times"
import "./utils/chunks"
import "./utils/cli"

import "./styles"

type FileMeta = object
  path: string
  lastModifiedTime: times.Time
  outputPath: string

type ThreadState = object
  page: int
  statePtr: ptr seq[seq[FileMeta]]

type AppState = ref object
  input: string
  output: string
  stylesheetPath: string
  poll: bool


var
  appState: AppState
  chan: Channel[string]
  threads: array[4, Thread[ThreadState]]
  lock: Lock
  fileData: seq[FileMeta]
  sharedFilesState {.guard: lock.}: seq[seq[FileMeta]]
  sharedFilesStatePtr = addr(sharedFilesState)

let maxThreads = len(threads)

# init app state
new(appState)

proc isSidebarFile(path: string): bool =
  let (_, tail) = splitPath(normalizedPath(path))
  if tail == "_sidebar.md":
    return true
  return false

proc writeDefaultStyles(path: string) =
  writeFile(joinPath(path, "style.css"), defaultStyles())

proc writeStyles(stylesheetPath: string, output: string) =
  copyFile(stylesheetPath, joinPath(output, "style.css"))

proc buildSidebar(): string =
  var sidebarContent: string = ""

  var sidebarFilePath = joinPath([appState.input, "_sidebar.md"])

  if fileExists(sidebarFilePath):
    let sidebar = open(sidebarFilePath);
    defer: sidebar.close
    sidebarContent = sidebar.readAll()

  if len(sidebarContent) == 0:
    return ""

  return r"""<section>
  <nav class="sidebar">""" & markdown(sidebarContent) &
  r"""</nav></section>"""

proc fileToHTML(path: string, output: string) =
  if fileExists(path) == false:
    return

  let f = open(path)
  defer: f.close()

  let fileContent = f.readAll()

  var html = r"""
  <head>
    <link rel="stylesheet" href="style.css" />
  </head>
  """
  html = html & r"""
  <body>
  <div class="layout-container">
  """ & buildSidebar() & r"""<section>""" & markdown(fileContent) & r"""</section></div>
  <script src="https://unpkg.com/@highlightjs/cdn-assets@11.5.1/highlight.min.js"></script>
  <script>
    hljs.highlightAll();
  </script>
  </body>
  """

  var targetPath = normalizedPath(path)
  let (_, tail) = splitPath(targetPath)

  let targetFile = changeFileExt(tail, "html");

  createDir(output);
  writeFile(joinPath(output, targetFile), html)

proc processFiles(files: seq[FileMeta]) =
  for file in files:
    if isSidebarFile(file.path):
      continue

    fileToHTML(file.path, file.outputPath)

proc getFilesToProcess(path: string, output: string): seq[FileMeta] =
  var fileCollection: seq[FileMeta]
  for _, filePath in walkDir(path, false, true):
    fileCollection.add(FileMeta(
        path: filePath,
        outputPath: output,
        lastModifiedTime: getLastModificationTime(filePath)
    ))
  return fileCollection

proc updateFileMeta(input: string, output: string) =
  ## Contruct and update the shared state with the new data of
  ## all files, this helps the threads to read through the shared
  ## data and have the latest data to compare any file changes with

  var files = getFilesToProcess(input, output)
  fileData = files
  withLock lock:
    sharedFilesState = createChunks(files, maxThreads)

proc watchBunch(tstate: ThreadState){.thread.} =
  ## Based on a given page / thread number , pick up a batch from
  ## the chunks and watch those files every second for changes
  ## if a file changes, send that through for recompilation and
  ## also ask the main thread to update the shared state

  while true:
    let data = tstate.statePtr[]
    let batchToProcess = data[tstate.page]

    for fileMeta in batchToProcess:
      let latestModTime = getLastModificationTime(fileMeta.path)
      if latestModTime != fileMeta.lastModifiedTime:
        chan.send(fileMeta.path)

    # force add a 750ms sleep to avoid forcing commands every millisecond
    sleep(750)


proc mudkip() =
  var files = getFilesToProcess(appState.input, appState.output)

  fileData = files

  if appState.stylesheetPath.len > 0:
    writeStyles(appState.stylesheetPath, appState.output)
  else:
    writeDefaultStyles(appState.output)

  processFiles(files)

  if appState.poll:
    echo "Watching: ", appState.input
    initLock(lock)
    chan.open()

    updateFileMeta(appState.input, appState.output)

    for i in 0..high(threads):
      createThread[ThreadState](threads[i], watchBunch, ThreadState(
        page: i,
        statePtr: sharedFilesStatePtr
      ))

    while true:
      # styles are polled by the main thread
      if appState.stylesheetPath.len > 0:
        writeStyles(appState.stylesheetPath, appState.output)
      else:
        writeDefaultStyles(appState.output)

      # wait on the channel for updates
      let tried = chan.tryRecv()
      if tried.dataAvailable:
        echo tried.msg
        updateFileMeta(appState.input, appState.output)
        if isSidebarFile(tried.msg):
          echo getCurrentTimeStamp() & info("Changed _sidebar, recompiling all files.")
          processFiles(files)
        else:
          echo getCurrentTimeStamp() & info("Recompiling: "), tried.msg
          fileToHTML(tried.msg, appState.output)

      sleep(500)

    joinThreads(threads)

proc ctrlCHandler() {.noconv.} =
  chan.close()
  deinitLock(lock)
  quit()

setControlCHook(ctrlCHandler)

proc cli() =
  var
    argCtr: int
    poll: bool
    input: string
    output: string
    stylesheetPath: string

  # default values
  input = "docs"
  output = "dist"
  poll = false

  for kind, key, value in getOpt():
    case kind

    # Positional arguments
    of cmdArgument:
      argCtr.inc

    # Switches
    of cmdLongOption, cmdShortOption:
      case key
      of "v", "version":
        writeVersion()
        quit()
      of "h", "help":
        writeHelp()
      of "p", "poll":
        poll = true
      of "stylesheet":
        stylesheetPath = value
      of "i", "in":
        input = value
      of "o", "out":
        output = value
      else:
        echo "Unknown option: ", key

    of cmdEnd:
      discard

  appState.input = input
  appState.output = output
  appState.stylesheetPath = stylesheetPath
  appState.poll = poll

  mudkip()
  echo success("Generated Docs in : "), output



when isMainModule:
  cli()
