import ../../dispatch, asyncdispatch

type
  RegisterUserCommand* = ref object of Command
    username: string
    password: string

proc handleRegisterUserCommand*(cmd: RegisterUserCommand): Future[void] {.async.} =
  echo "aaaaa"
