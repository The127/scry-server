import httpbeast

type
  ScryRequest* = ref object
    hbReq: Request

proc newScryRequest*(hbReq: Request): ScryRequest =
  ScryRequest(
    hbReq: hbReq,
  )

proc hbReq*(req: ScryRequest): Request =
  req.hbReq
