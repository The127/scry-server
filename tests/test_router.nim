import unittest, asyncdispatch
import ../src/router

suite "Router tests":
  test "router with prefix and one route":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter("api/v1")
      router.addRoute(
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      let req = newRequest(
        "api/v1/users",
      )

      # act
      await router.route(req)
  
      # assert
      check isCalled

    waitFor(doTest())

  test "router without prefix and one route":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter()
      router.addRoute(
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      let req = newRequest(
        "users",
      )

      # act
      await router.route(req)

      # assert
      check isCalled

    waitFor(doTest())

  test "router without prefix and multiple routes calls first":
    proc dotest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter()

      router.addRoute(
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      router.addRoute(
        "sessions",
        proc(req: Request): Future[void] {.async.} =
          return,
      )

      let req = newRequest(
        "users",
      )

      # act
      await router.route(req)

      #assert
      check isCalled

    waitFor(doTest())
      
  test "router without prefix and multiple routes calls second":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter()

      router.addRoute(
        "sessions",
        proc(req: Request): Future[void] {.async.} =
          return,
      )

      router.addRoute(
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      let req = newRequest(
        "users"
      )

      # act
      await router.route(req)

      # assert
      check isCalled

    waitFor(doTest())
