import router, asyncdispatch, httpx, config, options, request, routes/auth

proc fallback(params: RouteParams, req: ScryRequest): Future[void] {.async.} =
  req.hbReq.send("Not found", Http404)

proc healthEndpoint(params: RouteParams, req: ScryRequest): Future[void] {.async.} =
  req.hbReq.send("Healthy", Http404)


proc runServer*(settings: Config) =
  let r = newRouter[ScryRequest]("/api/v1", fallback)
  r.addRoute("GET", "health", healthEndpoint)
  r.addAuthRoutes()

  proc onRequest(req: Request): Future[void] {.async, gcsafe.} =
    let verb = req.httpMethod()
    if verb.isNone():
      req.send("Missing http verb", Http400)
    
    let path = req.path()
    if path.isNone():
      req.send("Missing path", Http400)

    await r.route(
      $verb.get(),
      path.get(),
      newScryRequest(
        hbReq = req,
      ),
    )

  run(onRequest, initSettings(
    port = Port(settings.server.port),
    bindAddr = settings.server.host,
  ))

