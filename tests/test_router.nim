import unittest, asyncdispatch
import ../src/router

suite "Router tests":
  test "router with prefix and one route":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter("api/v1")
      router.addRoute(
        "GET",
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      let req = newRequest(
        "GET",
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
        "GET",
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      let req = newRequest(
        "GET",
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
        "GET",
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      router.addRoute(
        "GET",
        "sessions",
        proc(req: Request): Future[void] {.async.} =
          return,
      )

      let req = newRequest(
        "GET",
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
        "GET",
        "sessions",
        proc(req: Request): Future[void] {.async.} =
          return,
      )

      router.addRoute(
        "GET",
        "users",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      let req = newRequest(
        "GET",
        "users"
      )

      # act
      await router.route(req)

      # assert
      check isCalled

    waitFor(doTest())

  test "router routes based on verb":
    proc doTest() {.async.} =
      # arrange
      var getCalled = false
      var postCalled = false
      let router = newRouter()

      router.addRoute(
        "GET",
        "users",
        proc(req: Request): Future[void] {.async.} =
          getCalled = true,
      )

      router.addRoute(
         "POST",
        "users",
        proc(req: Request): Future[void] {.async.} =
          postCalled = true,
      )

      let req = newRequest(
        "POST",
        "users"
      )

      # act
      await router.route(req)

      # assert
      check postCalled
      check getCalled == false

    waitFor(doTest())

  test "route with matcher":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter()

      router.addRoute(
        "GET",
        "users/:userId",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true,
      )

      let req = newRequest(
        "GET",
        "users/0"
      )
      
      # act
      await router.route(req)

      # assert
      check isCalled

    waitFor(doTest())

  test "fallback is called":
    proc doTest() {.async.} =
      var isCalled = false
      let router = newRouter(
        "api/v1",
        proc(req: Request): Future[void] {.async.} =
          isCalled = true
      )

      let req = newRequest(
        "GET",
        "foo",
      )

      # act
      await router.route(req)

      # assert
      check isCalled

    waitFor(doTest())

  test "router with and without matcher":
    proc doTest() {.async.} =
      var correctCalled = false
      var wrongCalled = false
      let router = newRouter("api/v1")

      router.addRoute(
        "GET",
        "users/:userId/messages",
        proc(req: Request): Future[void] {.async.} =
          wrongCalled = true,
      )

      router.addRoute(
        "GET",
        "users/userId/messages",
        proc(req: Request): Future[void] {.async.} =
          correctCalled = true,
      )

      let req = newRequest(
        "GET",
        "api/v1/users/userId/messages"
      )

      # act
      await router.route(req)

      # assert
      check correctCalled
      check wrongCalled == false

    waitFor(doTest())
