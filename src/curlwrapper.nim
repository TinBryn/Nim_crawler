import httpclient
import parseutils
import pages

proc request*(url: string, met: NodeRequest): tuple[code: int, body: string] =
  var client = newHttpClient()
  case met:
  of nrGet:
    let res = client.get(url)
    var code: int
    discard parseInt(res.status, code, 0)
    (code, res.body)
  of nrHead:
    let res = client.head(url)
    var code: int
    discard parseInt(res.status, code, 0)
    (code, "")

when isMainModule:
  when defined ssl:
    const url = "https://www.google.com"
  else:
    const url = "http://www.google.com"

  echo url
  echo request(url, nrHead)
