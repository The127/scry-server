import repos/userRepo

type
  UoW* = ref object
    users: UserRepo

proc newUoW*(): UoW =
  UoW(
    users: newPgUserRepo(),
  )

proc users*(uow: UoW): UserRepo =
  uow.users

proc save*(uow: UoW) =
  # TODO: disable triggers
  uow.users.save()
  # TODO: enable triggers
