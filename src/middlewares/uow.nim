import ../dispatch, asyncdispatch, ../uow, typeinfo

proc uowMiddleware*(cmd: Command, ctx: Context, next: Next): Future[void] {.async.} =
  var uow = newUoW()
  ctx.with("uow", toAny(uow))
  await next(cmd, ctx)
  uow.save()

proc getUoW*(ctx: Context): UoW =
  let value = ctx["uow"]
  return cast[UoW](value.getPointer())
