import ../../dispatch, asyncdispatch, ../../middlewares/uow, ../../uow

type
  CreateInitialAdminCommand* = ref object of Command
    username*: string
    displayName*: string
    password*: string

proc handleCreateInitialAdmin*(cmd: CreateInitialAdminCommand, ctx: Context): Future[void] {.async.} =
  ctx.getUoW().save()
  echo "aaaaa"

registerHandler(CreateInitialAdminCommand, handleCreateInitialAdmin)
