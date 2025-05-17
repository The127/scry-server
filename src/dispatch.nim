import macros

type
  Command* = ref object of RootObj

macro registerHandler*(cmdType: typedesc, handler: untyped): untyped =
  quote do:
    proc dispatch(cmd: `cmdType`): Future[void] {.async.} =
      await `handler`(cmd)
