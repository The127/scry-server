import config, server, dispatch, middlewares/uow, db

let settings* = loadConfig()

echo sqlMigrations

registerMiddleware(uowMiddleware)
runServer(settings)
