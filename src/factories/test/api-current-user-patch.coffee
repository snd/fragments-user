module.exports.testApiCurrentUserPatchForbidden = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiCurrentUser
  requestPromise
  insertUser
) ->
  (test) ->
    pgDropCreateMigrate()
      .then ->
        insertUser
          email: 'test@example.com'
          name: 'exampleuser'
          password: 'topsecret'
          rights: ''
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
          url: envStringBaseUrl + urlApiCurrentUser()
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 403

        shutdown()
      .then ->
        test.done()

module.exports.testApiCurrentUserPatchUnprocessable = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiCurrentUser
  requestPromise
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
          url: envStringBaseUrl + urlApiCurrentUser()
          body:
            email: 'dkjdlkf'
            name: ''
            password: ''
            rights: 'canAccessAllAndEverything # trying to escalate own rights should fail'
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'must not be the empty string'
          password: 'must not be the empty string'
          email: 'must be an email address'
          rights: 'you are not allowed to set your own rights'

        shutdown()
      .then ->
        test.done()

module.exports.testApiCurrentUserPatchUnprocessableTaken = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiCurrentUser
  requestPromise
  insertUser
) ->
  (test) ->
    pgDropCreateMigrate()
      .bind({})
      .then ->
        insertUser
          email: 'test@example.com'
          name: 'exampleuser'
          password: 'topsecret'
          rights: 'canAccessCockpit'
      .then ->
        insertUser
          email: 'othertest@example.com'
          name: 'otherexampleuser'
          password: 'topsecret'
          rights: 'canAccessCockpit'
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
        this.token = response.body.token

        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiCurrentUser()
          body:
            email: 'othertest@example.com'
            name: 'otherexampleuser'
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
          url: envStringBaseUrl + urlApiCurrentUser()
          body:
            email: 'othertest@example.com'
            name: 'exampleuser'
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
          url: envStringBaseUrl + urlApiCurrentUser()
          body:
            email: 'test@example.com'
            name: 'otherexampleuser'
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

module.exports.testApiCurrentUserPatchOkNoChange = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiCurrentUser
  requestPromise
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
          url: envStringBaseUrl + urlApiCurrentUser()
          body:
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'test@example.com'
        test.equal response.body.name, 'exampleuser'
        test.equal response.body.rights, 'canAccessCockpit'

        shutdown()
      .then ->
        test.done()

module.exports.testApiCurrentUserPatchOkChange = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  urlApiCurrentUser
  requestPromise
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
          url: envStringBaseUrl + urlApiCurrentUser()
          body:
            email: 'changedtest@example.com'
            name: 'changedexampleuser'
            password: 'changedtopsecret'
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'changedtest@example.com'
        test.equal response.body.name, 'changedexampleuser'
        test.equal response.body.rights, 'canAccessCockpit'

        shutdown()
      .then ->
        test.done()
