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
        "api/v1/users/:userId",
      )

      # act
      await router.route(req)
  
      # assert
      check isCalled

    waitFor(doTest())


