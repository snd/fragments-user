module.exports.testApiUserPatchForbidden = (
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
          method: 'PATCH'
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

module.exports.testApiUserPatchUnprocessable = (
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
          rights: 'canAccessCockpit\ncanUpdateUsers'
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
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(2)
          headers:
            authorization: "Bearer #{token}"
          json: true
          body:
            email: 'dkjdlkf'
            name: ''
            password: ''
            rights: 'canAccessAllAndEverything'
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'must not be the empty string'
          password: 'must not be the empty string'
          email: 'must be an email address'

        shutdown()
      .then ->
        test.done()

module.exports.testApiUserPatchUnprocessableTaken = (
) ->
  (test) ->
    test.done()

module.exports.testApiUserPatchOkNoChange = (
) ->
  (test) ->
    test.done()

module.exports.testApiUserPatchOkChange = (
) ->
  (test) ->
    test.done()
