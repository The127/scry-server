import asyncdispatch, ../router, ../server, ../request, httpbeast, jsony, options

type
  InitialAdminRequestDto = object
    username: string
    displayName: string
    password: string

proc initialAdminEndpoint(params: RouteParams, req: ScryRequest): Future[void] {.async} =
  let requestDto = req.hbReq.body().get().fromJson(InitialAdminRequestDto)
  echo requestDto
  req.hbReq.send("register endpoint", Http501)

proc addAuthRoutes*(router: Router[ScryRequest]) =
  router.addRoute("POST", "auth/initial-admin", initialAdminEndpoint)
  return
