import macros, asyncdispatch

type
  Command* = ref object of RootObj
  Next* = proc(cmd: Command): Future[void] {.async.}
  Middleware* = proc(cmd: Command, next: Next): Future[void] {.async.}

var middlewares: seq[Middleware] = @[]

proc registerMiddleware*(mw: Middleware) =
  middlewares.add(mw)

macro registerHandler*(cmdType: typedesc, handler: untyped): untyped =
  quote do:
    proc dispatch(cmd: `cmdType`): Future[void] {.async.} =
      var chain: Next = proc(cmd: Command): Future[void] {.async.} =
        await `handler`(`cmdType`(cmd))

      for middleware in middlewares:
        let next = chain
        let current = middleware
        chain = proc(cmd: Command): Future[void] {.async.} =
          await current(cmd, next)

      await chain(cmd)
