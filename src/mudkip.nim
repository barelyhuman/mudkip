import parseopt
import "std/os"
import "markdown"
import "./styles"


proc writeVersion() =
  echo getAppFilename().extractFilename(), " 0.1.0"

proc writeHelp() =
  writeVersion()
  echo """

  -h, --help        : show help
  -v, --version     : show version
  -p, --poll        : poll every few seconds for changes
  -i, --in          : folder to convert (contains markdown files) (default: docs)
  -o, --out         : folder to place the converted files (default: dist)
  --stylesheet      : custom stylesheet
  """
  quit()


proc writeDefaultStyles(path:string) =
  writeFile(joinPath(path,"style.css"),defaultStyles())

proc writeStyles(stylesheetPath:string,output:string)=
  copyFile(stylesheetPath,joinPath(output,"style.css"))

proc fileToMarkdown(path:string,output:string)= 
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
  """ & markdown(fileContent) & r"""
  <script src="https://unpkg.com/@highlightjs/cdn-assets@11.5.1/highlight.min.js"></script>
  <script>
    hljs.highlightAll();
  </script>
  </body>
  """

  var targetPath = normalizedPath(path)
  let (_,tail) = splitPath(targetPath)

  let targetFile = changeFileExt(tail,"html");

  createDir(output);
  writeFile(joinPath(output,targetFile),html)


proc processDirectory(path:string,output:string)=
  for _,filePath in walkDir(path,false,true):
      fileToMarkdown(filePath,output)

proc mudkip(input:string,output:string,stylesheetPath:string,poll:bool)=
  processDirectory(input,output)
  if stylesheetPath.len > 0:
    writeStyles(stylesheetPath,output)
  else: 
    writeDefaultStyles(output)
  
  if poll:
    echo "Watching: ", input


  while poll:
    processDirectory(input,output)
    if stylesheetPath.len > 0:
      writeStyles(stylesheetPath,output)
    else: 
      writeDefaultStyles(output)
    sleep(3000)



proc ctrlc() {.noconv.} =
  quit()

setControlCHook(ctrlc)

proc cli()=

  var
    argCtr : int
    poll : bool
    input : string
    output : string
    stylesheetPath : string

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
      of "p","poll":
        poll = true
      of "stylesheet":
        stylesheetPath = value
      of "i","in":
          input = value
      of "o","out":
          output = value
      else:
        echo "Unknown option: ", key

    of cmdEnd:
      discard
  
  mudkip(input,output,stylesheetPath,poll)



when isMainModule:
  cli()
