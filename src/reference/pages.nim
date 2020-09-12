import uri

type
  NodeStatus* = enum
    nsNone
    nsEnqueued
    nsSuccess
    nsFailure

  NodeRequest* = enum
    nrGet
    nrHead

  Page* = ref object
    uri*: Uri
    request*: NodeRequest
    status*: NodeStatus
    error*: string
    response*: int

proc newPage*(uri: Uri, status = nsNone): Page =
  ##
  Page(uri: uri, status: status)
