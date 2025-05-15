import parsetoml

type
  ServerConfig = object
    host: string
    port: int

  Config = object
    server: ServerConfig

proc loadConfig*(path = "config.toml"): Config =
  let tbl = parsetoml.parseFile("config.toml")
  
  result.server.host = tbl["server"]["host"].getStr("localhost")
  result.server.port = tbl["server"]["port"].getInt(5974)

