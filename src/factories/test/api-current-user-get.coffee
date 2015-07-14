module.exports.testApiCurrentUserGetForbidden = (
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
        test.ok token?

        requestPromise(
          method: 'GET'
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

module.exports.testApiCurrentUserGetOk = (
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
          method: 'GET'
          url: envStringBaseUrl + urlApiCurrentUser()
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'test@example.com'
        test.equal response.body.name, 'exampleuser'
        test.equal response.body.rights, 'canAccessCockpit'
        test.ok not response.body.password?

        shutdown()
      .then ->
        test.done()
