import config, asyncdispatch, httpbeast

echo "hello world!"

let settings* = loadConfig()

proc onRequest(req: Request): Future[void] {.async.} =
  req.send("Hello World")

run(onRequest, initSettings(
  port = Port(settings.server.port),
  bindAddr = settings.server.host,
))

