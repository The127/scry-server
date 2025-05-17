import asyncdispatch, ../router, ../server, ../request, httpbeast

proc registerEndpoint(params: RouteParams, req: ScryRequest): Future[void] {.async} =
  req.hbReq.send("register endpoint", Http501)

proc addAuthRoutes*(router: Router[ScryRequest]) =
  return
