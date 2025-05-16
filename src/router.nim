import asyncdispatch, tables, options, strutils

type
  RouteParams* = TableRef[string, string]

  RequestHandler*[T] = proc(routeParams: RouteParams, req: T): Future[void] {.gcsafe, async.}

  RouteMatch[T] = object
    params: RouteParams
    handler: RequestHandler[T]

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

proc `[]`*(params: RouteParams, param: string): string =
  tables.`[]`(params, param)
  
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

proc doNothing[T](_: RouteParams, _: T): Future[void] {.async.} =
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

proc matchRoute[T](router: Router[T], verb: string, path: string): Option[RouteMatch[T]] =
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
      return none[RouteMatch[T]]()

  if current.leaf.isNone():
    return none[RouteMatch[T]]()

  let leaf = current.leaf.get()

  if not leaf.routes.hasKey(verb):
    return none[RouteMatch[T]]()

  let route = leaf.routes[verb]

  let params = newTable[string, string]()
  for i, v in route.paramNames:
    params[v] = values[i]

  return some(RouteMatch[T](
    params: params,
    handler: route.handler,
  ))

proc route*[T](router: Router[T], verb: string, path: string, req: T): Future[void] {.async.} =
  let match = router.matchRoute(verb, path)
    .get(RouteMatch[T](
      params: new(RouteParams),
      handler: router.fallback,
    ))
    
  await match.handler(match.params, req)
