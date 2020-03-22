import uri, strutils, re

proc hrefCleanup(href: string): string =
  href.replace " ", "%20"

proc absolutizePath*(path, base: string): string =
  ## an empty path is absolute an empty path
  ## if the path matches "/foo/bar" but not "foo/bar" or "/./foo/bar"
  ## it is an absolute path and is just returned
  if path == "" or path[0] == '/' and path[1] != '.':
    return path
  
  var sections: seq[string] = @[]
  for section in base.split '/':
    if section.len > 0:
      sections.add section

  for section in path.split '/':
    if section.len > 0:
      sections.add section
  
  var res: seq[string] = @[]
  for section in sections:
    if section == "..":
      discard res.pop
    elif section != ".":
      res.add section
  
  for s in res:
    result &= "/" & s

proc getUrls(
  errors: var seq[string],
  paths: seq[string],
  parent: Uri
  ): seq[Uri] =
  ##
  for path in paths:
    ##
    let href = hrefCleanup(path)

    if href[0] == '#' or href[0..5] == "mailto":
      continue
  
    var hrefUri: Uri
    hrefUri = parseUri(href)

    if hrefUri.scheme.len == 0:
      hrefUri.scheme = parent.scheme
    if hrefUri.hostname.len == 0 and hrefUri.path[0..1] == "//":
      ##
      let found = hrefUri.path.find('/', 2)
      hrefUri.hostname = hrefUri.path[2..found-2]
      hrefUri.path = hrefUri.path[found..^1]
    if hrefUri.hostname.len == 0 or hrefUri.hostname == ".":
      hrefUri.hostname = parent.hostname
      hrefUri.port = parent.port
      hrefUri.path = absolutizePath(hrefUri.path, parent.path)

proc getUrlStrings(body: string): seq[string] =
  ##
  const regexes: seq[Regex] = @[
    """<a [^>]*href="([^"]*)""".re,
    """<link [^>]*href="([^"]*)"""".re,
    """<script [^>]*src="([^"]*)"""".re
    ]
  for regex in regexes:
    for match in body.findAll(regex):
      ##
      result.add(match)
    


proc getNeighbors*(errors: var seq[string], body: string, uri: Uri): seq[Uri] =
  getUrls(errors, getUrlStrings(body), uri)


