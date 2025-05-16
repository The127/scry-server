import asyncdispatch

type
  Request* = ref object
    url: string

  RequestHandler* = proc(req: Request): Future[void] {.gcsafe, async.}
    
  Route = object
    url: string
    handler: RequestHandler
    
  Router* = ref object
    prefix: string
    routes: seq[Route]
  
proc newRequest*(url: string): Request =
  Request(
    url: url,
  )

proc url*(req: Request): string =
  req.url

proc newRouter*(prefix = ""): Router =
  Router(prefix: prefix, routes: @[])

proc addRoute*(router: Router, route: string, handler: RequestHandler) =
  let route = if router.prefix == "":
      route
    else:
      router.prefix & "/" & route

  router.routes.add(Route(
    url: route,
    handler: handler,
  ))

proc route*(router: Router, request: Request): Future[void] {.async.} =
  for route in router.routes:
    if route.url == request.url:
      await route.handler(request)
      return
