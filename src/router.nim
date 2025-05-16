import asyncdispatch

type
  Request* = ref object
    verb: string
    url: string

  RequestHandler* = proc(req: Request): Future[void] {.gcsafe, async.}
    
  Route = object
    verb: string
    url: string
    handler: RequestHandler
    
  Router* = ref object
    prefix: string
    routes: seq[Route]
  
proc newRequest*(verb: string, url: string): Request =
  Request(
    verb: verb,
    url: url,
  )

proc url*(req: Request): string =
  req.url

proc newRouter*(prefix = ""): Router =
  Router(prefix: prefix, routes: @[])

proc addRoute*(router: Router, verb: string, route: string, handler: RequestHandler) =
  let route = if router.prefix == "":
      route
    else:
      router.prefix & "/" & route

  router.routes.add(Route(
    verb: verb,
    url: route,
    handler: handler,
  ))

proc route*(router: Router, request: Request): Future[void] {.async.} =
  for route in router.routes:
    if route.url == request.url and route.verb == request.verb:
      await route.handler(request)
      return
