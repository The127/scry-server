import config, server

echo "hello world!"

let settings* = loadConfig()

runServer(settings)
