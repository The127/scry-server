import macros, asyncdispatch, tables, typeinfo

type
  Context* = ref object
    data: Table[string, Any]
  Command* = ref object of RootObj
  Next* = proc(cmd: Command, ctx: Context): Future[void] {.async.}
  Middleware* = proc(cmd: Command, ctx: Context, next: Next): Future[void] {.async.}

proc newContext*(): Context =
  Context(
    data: initTable[string, Any](),
  )

proc with*(ctx: Context, key: string, value: Any): Context =
  ctx.data[key] = value
  return ctx

proc `[]`*(ctx: Context, key: string): Any =
  ctx.data[key]

var middlewares: seq[Middleware] = @[]

proc resetMiddlewares*() =
  middlewares = @[]

proc registerMiddleware*(mw: Middleware) =
  middlewares.add(mw)

macro registerHandler*(cmdType: typedesc, handler: untyped): untyped =
  quote do:
    proc dispatch(cmd: `cmdType`, ctx: Context): Future[void] {.async.} =
      var chain: Next = proc(cmd: Command, ctx: Context): Future[void] {.async.} =
        await `handler`(`cmdType`(cmd), ctx)

      for middleware in middlewares:
        let next = chain
        let current = middleware
        chain = proc(cmd: Command, ctx: Context): Future[void] {.async.} =
          await current(cmd, ctx, next)

      await chain(cmd, ctx)
