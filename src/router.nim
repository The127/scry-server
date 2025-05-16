import asyncdispatch, tables, options, strutils

type
  RequestHandler*[T] = proc(req: T): Future[void] {.gcsafe, async.}

  Route[T] = object
    paramNames: seq[string]
    handler: RequestHandler[T]

  RoutingLeaf[T] = object
    routes: TableRef[string, Route[T]]

  RoutingNode[T] = ref object
    staticChildren: TableRef[string, RoutingNode[T]]
    paramChild: Option[RoutingNode[T]]
    leaf: Option[RoutingLeaf[T]]
    
  Router*[T] = ref object
    prefix: string
    routingTree: RoutingNode[T]
    fallback: RequestHandler[T]
  
proc newRoutingLeaf[T](): RoutingLeaf[T] =
  RoutingLeaf[T](
    routes: newTable[string, Route[T]](),
  )

proc newRoutingNode[T](): RoutingNode[T] =
  RoutingNode[T](
    staticChildren: newTable[string, RoutingNode[T]](),
    paramChild: none[RoutingNode[T]](),
    leaf: none[RoutingLeaf[T]](),
  )

proc doNothing[T](req: T): Future[void] {.async.} =
  return

proc newRouter*[T](prefix = "", fallback: RequestHandler[T] = doNothing[T]): Router[T] =
  Router[T](
    prefix: prefix,
    routingTree: newRoutingNode[T](),
    fallback: fallback,
  )

proc addRoute*[T](router: Router[T], verb: string, route: string, handler: RequestHandler[T]) =
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
        current.paramChild = some(newRoutingNode[T]())

      current = current.paramChild.get()
      
    else:
      if not current.staticChildren.hasKey(segment):
        current.staticChildren[segment] = newRoutingNode[T]()

      current = current.staticChildren[segment]

  if current.leaf.isNone():
    current.leaf = some(newRoutingLeaf[T]())

  let leaf = current.leaf.get()
  
  if leaf.routes.hasKey(verb):
    raise newException(ValueError, "Route collission: " & verb & " - " & route)

  leaf.routes[verb] = Route[T](
    paramNames: paramNames,
    handler: handler,
  )

proc matchRoute[T](router: Router[T], verb: string, path: string): Option[RequestHandler[T]] =
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
      return none[RequestHandler[T]]()

  if current.leaf.isNone():
    return none[RequestHandler[T]]()

  let leaf = current.leaf.get()

  if not leaf.routes.hasKey(verb):
    return none[RequestHandler[T]]()

  # TODO: handle params
  let route = leaf.routes[verb]
  return some(route.handler)
    
proc route*[T](router: Router[T], verb: string, path: string, req: T): Future[void] {.async.} =
  let handler = router.matchRoute(verb, path)
    .get(router.fallback)
    
  await handler(req)
