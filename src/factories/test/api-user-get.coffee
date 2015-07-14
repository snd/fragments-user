module.exports.testApiUserGetForbidden = (
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
      .bind({})
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
        this.token = response.body.token

        requestPromise(
          method: 'GET'
          url: envStringBaseUrl + urlApiUsers(2)
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 403

        shutdown()
      .then ->
        test.done()

module.exports.testApiUserGetOk = (
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
          rights: 'canAccessCockpit\ncanReadUsers'
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
          method: 'GET'
          url: envStringBaseUrl + urlApiUsers(2)
          headers:
            authorization: "Bearer #{token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, 2

        shutdown()
      .then ->
        test.done()

module.exports.testApiUserGetSingleRight = (
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
      .bind({})
      .then ->
        insertUser
          email: 'test@example.com'
          name: 'exampleuser'
          password: 'topsecret'
          rights: 'canAccessCockpit\ncanReadUsers(2)'
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
        this.token = response.body.token

        requestPromise(
          method: 'GET'
          url: envStringBaseUrl + urlApiUsers(2)
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, 2

        requestPromise(
          method: 'GET'
          url: envStringBaseUrl + urlApiUsers(3)
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 403

        shutdown()
      .then ->
        test.done()

module.exports.testApiUserGetNotFound = (
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
      .bind({})
      .then ->
        insertUser
          email: 'test@example.com'
          name: 'exampleuser'
          password: 'topsecret'
          rights: 'canAccessCockpit\ncanReadUsers'
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
          method: 'GET'
          url: envStringBaseUrl + urlApiUsers(2)
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 404

        shutdown()
      .then ->
        test.done()
