import parsetoml

type
  ServerConfig = object
    host*: string
    port*: int

  Config = object
    server*: ServerConfig

const defaultConfig = Config(
  server: ServerConfig(
    host: "localhost",
    port: 5974,
  ),
)

proc loadConfig*(path = "config.toml"): Config =
  result = defaultConfig
  
  let tbl = try:
    parsetoml.parseFile("config.toml")
  except IOError:
    return

  if tbl["server"] != nil:
    result.server.host = tbl["server"]["host"].getStr(defaultConfig.server.host)
    result.server.port = tbl["server"]["port"].getInt(defaultConfig.server.port)
    
