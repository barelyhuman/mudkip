import parseopt
import std/os, htmlgen, locks, times, re, marshal, strutils
import "./utils/chunks"
import "./utils/cli"
import "./styles"
import "markdown"

import "./search"

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
  baseUrl: string


var
  appState: AppState
  chan: Channel[string]
  threads: array[4, Thread[ThreadState]]
  lock: Lock
  fileData: seq[FileMeta]
  sharedFilesState {.guard: lock.}: seq[seq[FileMeta]]
  sharedFilesStatePtr = addr(sharedFilesState)
  searchIndex: seq[SearchIndexItem]


const fuzzyJS = staticRead"mudkip.js"

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

proc writeMudkipJS(path: string) =
  writeFile(joinPath(path, "mudkip.js"), fuzzyJS)

proc writeSearchIndex(path: string) =
  writeFile(joinPath(path, "search.json"), $$searchIndex)

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

  if appState.baseUrl != "/":
    sidebarContent = replace(sidebarContent, re"\]\(\/",
        "]"&"("&appState.baseUrl)

  sidebarContent = replace(sidebarContent, "%baseurl%", appState.baseUrl)
  sidebarContent = replace(sidebarContent, "\\%baseurl\\%", "%baseurl%")

  return section(
    nav(class = "sidebar",
      markdown(sidebarContent)
    )
  )

proc addToSearchIndex(title: string, content: string,
    slug: string) =

  var tokens = content.split({'\n', '\t', ','})

  searchIndex.add(
    createSearchIndexItem(
      title = title,
      tokens = tokens,
      slug = slug
    )
  )

proc fileToHTML(path: string, output: string) =
  if fileExists(path) == false:
    return

  let f = open(path)
  defer: f.close()

  var fileContent = f.readAll()

  var fileNameToProcess = extractFilename(path)

  if not (fileNameToProcess.endsWith("html") or fileNameToProcess.endsWith("md")):
    return

  if appState.baseUrl != "/":
    fileContent = replace(fileContent, re"\]\(\/",
        "]"&"("&appState.baseUrl)

  fileContent = replace(fileContent, "%baseurl%", appState.baseUrl)
  fileContent = replace(fileContent, "\\%baseurl\\%", "%baseurl%")

  var compiledContentHTML = markdown(fileContent)

  var html = html(
      head(link(rel = "stylesheet", href = "style.css")),
      body(
        `div`(id = "search-container"),
        `div`(class = "layout-container",
            buildSidebar(),
            section(compiledContentHTML)
    ),
        script(src = "https://unpkg.com/@highlightjs/cdn-assets@11.5.1/highlight.min.js"),
        script("hljs.highlightAll()"),
        script(src = "mudkip.js")
    )
  )

  var targetPath = normalizedPath(path)
  let (_, tail) = splitPath(targetPath)

  let targetFile = changeFileExt(tail, "html");

  addToSearchIndex(
    title = path,
    content = fileContent,
    slug = targetFile
  )

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

  createDir(appState.output);

  if appState.stylesheetPath.len > 0:
    writeStyles(appState.stylesheetPath, appState.output)
  else:
    writeDefaultStyles(appState.output)

  writeMudkipJS(appState.output)

  processFiles(files)

  writeSearchIndex(appState.output)

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
    baseUrl: string
    stylesheetPath: string

  # default values
  input = "docs"
  output = "dist"
  poll = false
  baseUrl = "/"

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
      of "baseurl":
        baseUrl = value
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
  appState.baseUrl = baseUrl

  mudkip()
  echo success("Generated Docs in : "), output





when isMainModule:
  cli()
