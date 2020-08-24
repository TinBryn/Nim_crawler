import uri
import strutils
import re

proc cleanupHref(href: string): string =
  replace(href, " ", "%20")

proc absolutizePath*(path, basePath: string): string =
  if path == "":
    return ""

  if path[0] == '/' and path[1] != '.':
    return path

  var sections: seq[string]

  for section in basePath.split("/"):
    if section.len > 0:
      sections.add section
  
  if basePath[^1] != '/':
    discard sections.pop()

  for section in path.split("/"):
    if section.len > 0:
      sections.add section

  var output: seq[string]

  for section in sections:
    if section == "." or section == "":
      discard
    elif section == "..":
      discard output.pop()
    else:
      output.add section
    
  for section in output:
    result.add("/" & section)

proc getUrlsFromPage(pathsToFollow: seq[string], parentUri: Uri): (seq[Uri], seq[string]) =
  for path in pathsToFollow:
    let href = cleanupHref(path)

    if href[0] == '#':
      continue
    
    if href[0..5] == "mailto":
      continue
    
    var hrefUri =
      try:
        parseUri(href)
      except:
        result[1].add(getCurrentExceptionMsg() & " in url " & href)
        continue

    if hrefUri.scheme == "":
      hrefUri.scheme = parentUri.scheme
    
    if hrefUri.hostname == "" and hrefUri.path[0..1] == "//":
      let found = hrefUri.path.find("/", 2)
      hrefUri.hostname = hrefUri.path[2 .. found-3]
      hrefUri.path = hrefUri.path[0 .. found-1]
    
    if hrefUri.hostname == "" or hrefUri.hostname == ".":
      hrefUri.hostname = parentUri.hostname
      hrefUri.port = parentUri.port
      hrefUri.path = absolutizePath(hrefUri.path, parentUri.path)
    
    hrefUri.anchor = ""

    result[0].add(hrefUri)

let regexes = [
  re"<a [^>]*href=""([^""]*)""",
  re"<link [^>]*href=""([^""]*)""",
  re"<script [^>]*src=""([^""]*)"""
]

proc getUrlStringsFromDoc(body: string): seq[string] =
  for regex in regexes:
    for it in body.findAll(regex):
      result.add it

proc getNeighbors*(body: string, uri: Uri): (seq[Uri], seq[string]) =
  let urlStrings = getUrlStringsFromDoc(body)
  getUrlsFromPage(urlStrings, uri)
