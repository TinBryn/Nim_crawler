import httpclient
import parseutils
import pages

type
  CurlResult* = object
    code*: int
    body*: string

proc request*(url: string, met: NodeRequest): CurlResult =
  ##
  var client = newHttpClient()
  case met:
  of nrGet:
    let res = client.get(url)
    var code: int
    discard parseInt(res.status, code, 0)
    CurlResult(code: code, body: res.body)
  of nrHead:
    let res = client.head(url)
    var code: int
    discard parseInt(res.status, code, 0)
    CurlResult(code: code, body: "")

when isMainModule:
  when defined ssl:
    const url = "https://www.google.com"
  else:
    const url = "http://www.google.com"

  echo url
  echo request(url, nrHead)
