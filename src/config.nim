import parsetoml

type
  DbConfig = object
    host*: string
    port*: int
    database*: string
    user*: string
    password*: string
  
  ServerConfig = object
    host*: string
    port*: int

  Config* = object
    db*: DbConfig
    server*: ServerConfig

const defaultConfig = Config(
  server: ServerConfig(
    host: "localhost",
    port: 5974,
  ),
  db: DbConfig(
    host: "localhost",
    port: 5975,
    database: "scry",
    user: "user",
    password: "password",
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
    
  if tbl["db"] != nil:
    result.db.host = tbl["db"]["host"].getStr(defaultConfig.db.host)
    result.db.port = tbl["db"]["port"].getInt(defaultConfig.db.port)
    result.db.database = tbl["db"]["database"].getStr(defaultConfig.db.database)
    result.db.user = tbl["db"]["user"].getStr(defaultConfig.db.user)
    result.db.password = tbl["db"]["password"].getStr(defaultConfig.db.password)
