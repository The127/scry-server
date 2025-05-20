import config, server, dispatch, middlewares/uow

let settings* = loadConfig()

registerMiddleware(uowMiddleware)
runServer(settings)
