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
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiUsers
  requestPromise
  insertUser
) ->
  (test) ->
    pgDropCreateMigrate()
      .bind({})
      .then ->
        insertUser
          email: 'operator@example.com'
          name: 'operator'
          password: 'topsecret'
          rights: 'canAccessCockpit\ncanUpdateUsers'
      .then ->
        insertUser
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
          rights: ''
      .then (user) ->
        this.user = user
        command_serve('cockpit')
      .then ->
        requestPromise(
          method: 'POST'
          url: envStringBaseUrl + urlApiLogin()
          json: true
          body:
            username: 'operator'
            password: 'topsecret'
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        this.token = response.body.token

        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(this.user.id)
          body:
            email: 'operator@example.com'
            name: 'operator'
            password: 'topsecret'
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'taken'
          email: 'taken'

        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(this.user.id)
          body:
            email: 'operator@example.com'
            name: 'changed'
            password: 'topsecret'
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'

        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(this.user.id)
          body:
            email: 'changed@example.com'
            name: 'operator'
            password: 'topsecret'
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'taken'

        shutdown()
      .then ->
        test.done()

module.exports.testApiUserPatchOkNoChange = (
) ->
  (test) ->
    test.done()

module.exports.testApiUserPatchOkChange = (
) ->
  (test) ->
    test.done()
