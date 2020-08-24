import tables, sets, uri, pages, hashes

proc hash*(uri: Uri): Hash = hash $uri

type PageGraph* = ref object
  nodes: Table[Uri, Page]
  outgoing: Table[Uri, HashSet[Uri]]
  incomming: Table[Uri, HashSet[Uri]]

proc newGraph*(): PageGraph =
  PageGraph(
    nodes: initTable[Uri, Page](),
    outgoing: initTable[Uri, HashSet[Uri]](),
    incomming: initTable[Uri, HashSet[Uri]]())

proc hasKeyOrPut*(graph: var PageGraph, node: Uri): bool =
  result = graph.nodes.hasKeyOrPut(node, newPage(node))
  if not result:
    graph.outgoing[node] = initHashSet[Uri]()
    graph.incomming[node] = initHashSet[Uri]()

proc hasKey*(graph: PageGraph, node: Uri): bool =
  graph.nodes.hasKey(node)

proc `[]`*(graph: PageGraph, uri: Uri): Page =
  graph.nodes[uri]

proc `[]`*(graph: var PageGraph, uri: Uri): var Page =
  graph.nodes[uri]

proc addNeighbor*(graph: var PageGraph; start, finish: Uri) =
  graph.outgoing[start].incl(finish)
  graph.incomming[finish].incl(start)
