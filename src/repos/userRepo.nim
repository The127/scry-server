type
  UserRepo* = ref object of RootObj
  PgUserRepo = ref object of UserRepo

method save*(repo: UserRepo) {.base.} =
  discard

proc newPgUserRepo*(): UserRepo =
  PgUserRepo()

method save*(repo: PgUserRepo) =
  echo "pg save"
