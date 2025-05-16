import asyncdispatch, tables, options, strutils

type
  Request* = ref object
    verb: string
    url: string

  RequestHandler* = proc(req: Request): Future[void] {.gcsafe, async.}

  Route = object
    paramNames: seq[string]
    handler: RequestHandler

  RoutingLeaf = object
    routes: TableRef[string, Route]

  RoutingNode = ref object
    staticChildren: TableRef[string, RoutingNode]
    paramChild: Option[RoutingNode]
    leaf: Option[RoutingLeaf]
    
  Router* = ref object
    prefix: string
    routingTree: RoutingNode
    fallback: RequestHandler
  
proc newRequest*(verb: string, url: string): Request =
  Request(
    verb: verb,
    url: url,
  )

proc url*(req: Request): string =
  req.url

proc newRoutingLeaf(): RoutingLeaf =
  RoutingLeaf(
    routes: newTable[string, Route](),
  )

proc newRoutingNode(): RoutingNode =
  RoutingNode(
    staticChildren: newTable[string, RoutingNode](),
    paramChild: none[RoutingNode](),
    leaf: none[RoutingLeaf](),
  )

proc doNothing(req: Request): Future[void] {.async.} =
  return

proc newRouter*(prefix = "", fallback: RequestHandler = doNothing): Router =
  Router(
    prefix: prefix,
    routingTree: newRoutingNode(),
    fallback: fallback,
  )

proc addRoute*(router: Router, verb: string, route: string, handler: RequestHandler) =
  let route = if router.prefix == "":
      route
    else:
      router.prefix & "/" & route

  let segments = route.split('/')
  var current = router.routingTree
  var paramNames: seq[string] = @[]

  for segment in segments:
    if segment.startsWith(":"):
      let paramName = segment[1..^1]
      paramNames.add(paramName)

      if current.paramChild.isNone():
        current.paramChild = some(newRoutingNode())

      current = current.paramChild.get()
      
    else:
      if not current.staticChildren.hasKey(segment):
        current.staticChildren[segment] = newRoutingNode()

      current = current.staticChildren[segment]

  if current.leaf.isNone():
    current.leaf = some(newRoutingLeaf())

  let leaf = current.leaf.get()
  
  if leaf.routes.hasKey(verb):
    raise newException(ValueError, "Route collission: " & verb & " - " & route)

  leaf.routes[verb] = Route(
    paramNames: paramNames,
    handler: handler,
  )

proc matchRoute(router: Router, verb: string, path: string): Option[RequestHandler] =
  let segments = path.split('/')
  var values: seq[string] = @[]
  var current = router.routingTree

  for segment in segments:
    if current.staticChildren.hasKey(segment):
      current = current.staticChildren[segment]

    elif current.paramChild.isSome():
      current = current.paramChild.get()
      values.add(segment)

    else:
      return none[RequestHandler]()

  if current.leaf.isNone():
    return none[RequestHandler]()

  let leaf = current.leaf.get()

  if not leaf.routes.hasKey(verb):
    return none[RequestHandler]()

  # TODO: handle params
  let route = leaf.routes[verb]
  return some(route.handler)
    
proc route*(router: Router, request: Request): Future[void] {.async.} =
  let handler = router.matchRoute(request.verb, request.url)
    .get(router.fallback)
    
  await handler(request)
