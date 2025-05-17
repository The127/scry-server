import ../../dispatch, asyncdispatch

type
  CreateInitialAdminCommand* = ref object of Command
    username*: string
    displayName*: string
    password*: string

proc handleCreateInitialAdmin*(cmd: CreateInitialAdminCommand, ctx: Context): Future[void] {.async.} =
  echo "aaaaa"

registerHandler(CreateInitialAdminCommand, handleCreateInitialAdmin)
