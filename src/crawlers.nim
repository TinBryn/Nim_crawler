import graphs
import pages
import uri
import locks
import deques
import sets
import hashes
import os
import threadpool

proc hash*(uri: Uri): Hash = hash($uri)

type Crawler* = object
  numThreads {.guard:lock.}, maxThreads: int
  verbosity*: bool

  domain: Uri
  lock: Lock
  queue {.guard:lock.}: Deque[Uri]
  current {.guard:lock.}: HashSet[Uri]
  errors {.guard:lock.}: seq[string]
  graph {.guard:lock.}: PageGraph

proc newCrawler*(maxThreads: int): Crawler =
  result = Crawler(
    numThreads: 0,
    maxThreads: maxThreads,
    verbosity: false,
    queue: initDeque[Uri](),
    current: initHashSet[Uri](),
    graph: newGraph()
  )
  initLock(result.lock)

proc getNodeSync(crawler: var Crawler, uri: Uri): Page =
  withLock(crawler.lock):
    result = crawler.graph[uri]

proc crawlWithGet(crawler: var Crawler, uri: Uri) =
  ##

proc crawlWithHead(crawler: var Crawler, uri: Uri) =
  ##

proc uriShouldBeCrawledAsNode(uri: Uri): bool =
  ##

proc spawnCrawlingThread(crawler: var Crawler, uri: Uri) =
  ##
  {.locks:[crawler.lock].}:
    crawler.current.incl(uri)
    sleep 100
    if uri.uriShouldBeCrawledAsNode:
      spawn crawlWithGet(crawler, uri)
    else:
      spawn crawlWithHead(crawler, uri)

proc enqueue(crawler: var Crawler, uri: Uri) =
  {.locks:[crawler.lock].}:
    ##
    if not crawler.graph.addNode(uri):
      return

    echo "Enqueueing ", uri, " (queueu has size ", crawler.queue.len, ")"
    if crawler.numThreads < crawler.maxThreads:
      inc crawler.numThreads
      crawler.spawnCrawlingThread(uri)
    else:
      crawler.queue.addLast(uri)

proc noteError(crawler: var Crawler, err: string) =
  ##

proc finalizeCrawl(crawler: var Crawler, uri: Uri) =
  ##

proc crawl*(crawler: var Crawler, initialUrl: string, displayResults = true): PageGraph =
  ##
  let initial = parseUri(initialUrl)

  crawler.domain = initial
  crawler.domain.path = ""
  crawler.domain.query = ""
  crawler.domain.anchor = ""

  withLock(crawler.lock):
    crawler.enqueue(initial)

  while true:
    var queueSize: int
    var beingExplored: int
    withLock(crawler.lock):
      queueSize = crawler.queue.len
      beingExplored = crawler.current.len

    if queueSize == 0 and beingExplored == 0:
      break
    if crawler.verbosity:
      echo "Crawling, queue has length ", queueSize,
        ", currently exploring ", beingExplored, " nodes"

    sleep 1000 # microseconds

  {.locks:[crawler.lock].}:
    if displayResults:
      echo "\n\nDone crawling! We explored ", crawler.graph.len, " urls!\n"

      if crawler.errors.len == 0:
        echo "No errors found!\n"
      else:
        echo "Here are all the complaints found:\n"
        for error in crawler.errors:
          echo error
        echo ""
    crawler.graph
