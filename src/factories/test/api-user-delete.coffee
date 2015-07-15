module.exports.testApiUserDeleteForbidden = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiUsers
  requestPromise
  insertFakeUsers
  insertUser
) ->
  (test) ->
    pgDropCreateMigrate()
      .then ->
        insertUser
          email: 'test@example.com'
          name: 'exampleuser'
          password: 'topsecret'
          rights: 'canAccessCockpit'
      .then ->
        insertFakeUsers(3)
      .then ->
        command_serve('cockpit')
      .then ->
        requestPromise(
          method: 'POST'
          url: envStringBaseUrl + urlApiLogin()
          json: true
          body:
            username: 'exampleuser'
            password: 'topsecret'
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        token = response.body.token

        requestPromise(
          method: 'DELETE'
          url: envStringBaseUrl + urlApiUsers(2)
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 403

        shutdown()
      .then ->
        test.done()

module.exports.testApiUserDeleteOk = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiUsers
  requestPromise
  insertFakeUsers
  insertUser
) ->
  (test) ->
    pgDropCreateMigrate()
      .then ->
        insertUser
          email: 'test@example.com'
          name: 'exampleuser'
          password: 'topsecret'
          rights: 'canAccessCockpit\ncanDeleteUsers'
      .then ->
        insertFakeUsers(3)
      .then ->
        command_serve('cockpit')
      .then ->
        requestPromise(
          method: 'POST'
          url: envStringBaseUrl + urlApiLogin()
          json: true
          body:
            username: 'exampleuser'
            password: 'topsecret'
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        token = response.body.token

        requestPromise(
          method: 'DELETE'
          url: envStringBaseUrl + urlApiUsers(2)
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200

        # TODO test that user is actually deleted
        shutdown()
      .then ->
        test.done()