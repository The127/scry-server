import router, asyncdispatch, httpbeast, config, options, request, routes/auth

proc fallback(params: RouteParams, req: ScryRequest): Future[void] {.async.} =
  req.hbReq.send("Not found")

proc healthEndpoint(params: RouteParams, req: ScryRequest): Future[void] {.async.} =
  req.hbReq.send("Healthy", Http404)

proc runServer*(settings: Config) =
  let router = newRouter[ScryRequest]("/api/v1", fallback)

  router.addRoute("GET", "health", healthEndpoint)
  router.addAuthRoutes()

  proc onRequest(req: Request): Future[void] {.async.} =
    let verb = req.httpMethod()
    if verb.isNone():
      req.send("Missing http verb", Http400)
    
    let path = req.path()
    if path.isNone():
      req.send("Missing path", Http400)
    
    await router.route(
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

