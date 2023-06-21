type SearchIndexItem* = object
  title: string
  slug: string
  contentTokens: seq[string]

  
proc createSearchIndexItem*(title:string ,tokens:seq[string] ,slug:string): SearchIndexItem = 
    return SearchIndexItem(
            title:title,
            slug:slug,
            contentTokens:tokens)