import graphs

type Crawler* = ref object

proc newCrawler*(): Crawler =
  Crawler()
