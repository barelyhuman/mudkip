import dom
import fuzzysearch
import jsony
import std/strformat,strutils


type SearchResult = object
  element: string
  slug: string
  count: int
  score: int 

type SearchIndexItem = object
  title: string
  slug: string
  contentTokens: seq[string]
  displayContent: string

type SearchIndex = seq[SearchIndexItem]

var searchDB: SearchIndex

proc sort[T](x: var openArray[T]; cmp: proc(a, b: T): int) {.importcpp:
  "#.sort(#)", nodecl.}

proc onInput(e: Event) {.exportc.} =
  let searchContainer = document.getElementById"search-results"
  var matches: seq[SearchResult]

  searchContainer.innerHTML = ""

  var input = e.target.value

  if input == "":
    return

  for item in searchDB:
    var title = item.slug.replace(".html","")
    for token in item.contentTokens:
      var (score, match) = fuzzyMatch(input, cstring(token))
      

      if match:
        var exists = false
        for i,m in matches:
          if m.slug == item.slug:
            exists = true
            matches[i].count =  m.count + 1
            var webNode = fmt"<a href='{item.slug}'>{title}({matches[i].count} matches)</a>"
            matches[i].element = webNode

        if not exists:
          var webNode = fmt"<a href='{item.slug}'>{title}(1 match)</a>"
          var sResult:SearchResult
          sResult.slug = item.slug
          sResult.element = webNode
          sResult.score = score
          sResult.count = 0
          matches.add(sResult)

  matches.sort(proc(a, b: auto): int = b.score - a.score)
  
  for m in matches:
    var container = document.createElement("div")
    container.classList.add("mudkip-search-item")
    container.innerHTML = cstring(m.element)
    searchContainer.appendChild(container)



proc onDOMLoaded(e: Event) {.exportc.} =
  # set theme select value
  echo "loaded"
  let seachContainer = document.getElementById"search-container"
  let searchResults = document.createElement"div"
  searchResults.id = "search-results"
  let seachInp = document.createElement"input"
  seachInp.setAttribute("type","text")
  seachInp.setAttribute("placeholder", "Search")
  var dbString: cstring
  {.emit: """
    var request = new XMLHttpRequest();
    request.open("GET", "search.json", false);
    request.send(null);
    `dbString` = request.responseText
  """.}

  var s = $(dbString)
  searchDB = s.fromJSON(SearchIndex)

  seachInp.addEventListener("keyup", onInput)
  seachContainer.appendChild(seachInp)
  seachContainer.appendChild(searchResults)


window.addEventListener("DOMContentLoaded", onDOMLoaded)