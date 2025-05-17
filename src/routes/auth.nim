import asyncdispatch, ../router, ../server, ../request, httpx, jsony, options, ../commands/auth/createInitialAdmin, ../dispatch

type
  InitialAdminRequestDto = object
    username: string
    displayName: string
    password: string

proc initialAdminEndpoint(params: RouteParams, req: ScryRequest): Future[void] {.async.} =
  let requestDto = req.hbReq.body().get().fromJson(InitialAdminRequestDto)
  let command = CreateInitialAdminCommand(
    username: requestDto.username,
    displayName: requestDto.displayName,
    password: requestDto.password,
  )

  await dispatch(command, newContext())
  
  req.hbReq.send("ok")

proc addAuthRoutes*(router: Router[ScryRequest]) =
  router.addRoute("POST", "auth/initial-admin", initialAdminEndpoint)
  return
