import macros, os, strutils, algorithm, sequtils

macro slurpSqlFiles(dirPath: static[string]): untyped =
  let fileListStr = staticExec("ls " & dirPath)
  let fileNames = fileListStr.splitLines().filterIt(it.endsWith(".sql")).sorted()

  result = newNimNode(nnkBracket)
  for file in fileNames:
    result.add(nnkTupleConstr.newTree(
      newLit(file),
      newLit(staticRead(dirPath / file)),
    ))

const sqlMigrations* = slurpSqlFiles("migrations")
