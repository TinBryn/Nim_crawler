import tables
import sets
import uri
import pages
import hashes

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

proc len*(graph: PageGraph): Natural =
  graph.nodes.len

proc addNode*(graph: var PageGraph, uri: Uri): bool =
  result = uri notin graph.nodes
  if result:
    graph.nodes[uri] = newPage(uri, nsEnqueued)

proc `[]`*(graph: PageGraph, uri: Uri): Page =
  graph.nodes[uri]

proc `[]`*(graph: var PageGraph, uri: Uri): var Page =
  graph.nodes[uri]

iterator parents*(graph: PageGraph, uri: Uri): Uri =
  for parent in graph.incomming[uri]:
    yield parent

proc addNeighbor*(graph: var PageGraph; start, finish: Uri) =
  graph.outgoing[start].incl(finish)
  graph.incomming[finish].incl(start)
