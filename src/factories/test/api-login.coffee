module.exports.testApiLoginUnprocessableNoBody = (
  command_serve
  shutdown
  envStringBaseUrl
  urlApiLogin
  requestPromise
) ->
  (test) ->
    command_serve('cockpit')
      .then ->
        requestPromise(
          method: 'POST'
          url: envStringBaseUrl + urlApiLogin()
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          username: 'must not be null or undefined'
          password: 'must not be null or undefined'
        shutdown()
      .then ->
        test.done()

module.exports.testApiLoginUnprocessableInvalidPassword = (
  command_serve
  shutdown
  envStringBaseUrl
  urlApiLogin
  requestPromise
) ->
  (test) ->
    command_serve('cockpit')
      .then ->
        requestPromise(
          method: 'POST'
          url: envStringBaseUrl + urlApiLogin()
          json: true
          body:
            username: 'exampleuser'
            password: 'open'
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          password: 'must be at least 8 characters long'
        shutdown()
      .then ->
        test.done()

module.exports.testApiLoginUnprocessableUserNotFound = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
  requestPromise
) ->
  (test) ->
    pgDropCreateMigrate()
      .then ->
        command_serve('cockpit')
      .then ->
        requestPromise(
          method: 'POST'
          url: envStringBaseUrl + urlApiLogin()
          json: true
          body:
            username: 'exampleuser'
            password: 'opensesame'
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body, 'invalid username or password'
        shutdown()
      .then ->
        test.done()

module.exports.testApiLoginUnprocessableWrongPassword = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
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
            username: 'test@example.com'
            password: 'opensesame'
        )
      .then ([response]) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body, 'invalid username or password'
        shutdown()
      .then ->
        test.done()

module.exports.testApiLoginOk = (
  command_serve
  pgDropCreateMigrate
  shutdown
  envStringBaseUrl
  urlApiLogin
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
        # login with email
        requestPromise(
          method: 'POST'
          url: envStringBaseUrl + urlApiLogin()
          json: true
          body:
            username: 'test@example.com'
            password: 'topsecret'
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        token = response.body.token
        test.ok token?
        test.equal response.body.user.email, 'test@example.com'
        test.equal response.body.user.name, 'exampleuser'
        test.equal response.body.user.rights, ''
        test.ok not response.body.user.password?

        # login with username
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
        test.ok token?
        test.equal response.body.user.email, 'test@example.com'
        test.equal response.body.user.name, 'exampleuser'
        test.equal response.body.user.rights, ''
        test.ok not response.body.user.password?

        shutdown()
      .then ->
        test.done()
