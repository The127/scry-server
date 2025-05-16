import unittest, asyncdispatch
import ../src/router

type TestReq = object

suite "Router tests":
  test "router with prefix and one route":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter[TestReq]("api/v1")
      router.addRoute(
        "GET",
        "users",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          isCalled = true,
      )

      # act
      await router.route("GET", "api/v1/users", TestReq())
  
      # assert
      check isCalled

    waitFor(doTest())

  test "router without prefix and one route":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter[TestReq]()
      router.addRoute(
        "GET",
        "users",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          isCalled = true,
      )

      # act
      await router.route("GET", "users", TestReq())

      # assert
      check isCalled

    waitFor(doTest())

  test "router without prefix and multiple routes calls first":
    proc dotest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter[TestReq]()

      router.addRoute(
        "GET",
        "users",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          isCalled = true,
      )

      router.addRoute(
        "GET",
        "sessions",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          return,
      )

      # act
      await router.route("GET", "users", TestReq())

      #assert
      check isCalled

    waitFor(doTest())
      
  test "router without prefix and multiple routes calls second":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter[TestReq]()

      router.addRoute(
        "GET",
        "sessions",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          return,
      )

      router.addRoute(
        "GET",
        "users",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          isCalled = true,
      )

      # act
      await router.route("GET", "users", TestReq())

      # assert
      check isCalled

    waitFor(doTest())

  test "router routes based on verb":
    proc doTest() {.async.} =
      # arrange
      var getCalled = false
      var postCalled = false
      let router = newRouter[TestReq]()

      router.addRoute(
        "GET",
        "users",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          getCalled = true,
      )

      router.addRoute(
         "POST",
        "users",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          postCalled = true,
      )

      # act
      await router.route("POST", "users", TestReq())

      # assert
      check postCalled
      check getCalled == false

    waitFor(doTest())

  test "route with matcher":
    proc doTest() {.async.} =
      # arrange
      var isCalled = false
      let router = newRouter[TestReq]()

      router.addRoute(
        "GET",
        "users/:userId",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          isCalled = true,
      )

      # act
      await router.route("GET", "users/0", TestReq())

      # assert
      check isCalled

    waitFor(doTest())

  test "fallback is called":
    proc doTest() {.async.} =
      var isCalled = false
      let router = newRouter[TestReq](
        "api/v1",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          isCalled = true
      )

      # act
      await router.route("GET", "foo", TestReq())

      # assert
      check isCalled

    waitFor(doTest())

  test "router with and without matcher":
    proc doTest() {.async.} =
      var correctCalled = false
      var wrongCalled = false
      let router = newRouter[TestReq]("api/v1")

      router.addRoute(
        "GET",
        "users/:userId/messages",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          wrongCalled = true,
      )

      router.addRoute(
        "GET",
        "users/userId/messages",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          correctCalled = true,
      )

      # act
      await router.route("GET", "api/v1/users/userId/messages", TestReq())

      # assert
      check correctCalled
      check wrongCalled == false

    waitFor(doTest())

  test "extracts route params":
    proc doTest() {.async.} =
      # arrange
      var receivedParams: RouteParams = new(RouteParams)
      let router = newRouter[TestReq]()

      router.addRoute(
        "GET",
        "users/:userId/messages/:messageId/details",
        proc(params: RouteParams, req: TestReq): Future[void] {.async.} =
          receivedParams = params,  
      )

      # act
      await router.route("GET", "users/127/messages/69/details", TestReq())

      # assert
      check receivedParams["userId"] == "127"
      check receivedParams["messageId"] == "69"
      
    waitFor(doTest())
