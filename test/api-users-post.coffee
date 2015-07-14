app = require '../app'

module.exports =

  'can not create user without right canCreateUsers': (test) ->
    app (
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
            method: 'POST'
            url: envStringBaseUrl + urlApiUsers()
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'with right canCreateUsers can not create user with invalid data': (test) ->
    app (
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
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanCreateUsers'
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
            method: 'POST'
            url: envStringBaseUrl + urlApiUsers()
            body:
              email: 'dkjdlkf'
              name: ''
              password: ''
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 422
          test.deepEqual response.body,
            name: 'must not be the empty string'
            password: 'must not be the empty string'
            email: 'must be an email address'
            rights: 'must not be null or undefined'

          shutdown()
        .then ->
          test.done()

  'with right canCreateUsers can not create user with existing email and/or name': (test) ->
    app (
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
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanCreateUsers'
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
            method: 'POST'
            url: envStringBaseUrl + urlApiUsers()
            body:
              email: 'test@example.com'
              name: 'user'
              password: 'opensesame'
              rights: ''
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 422
          test.deepEqual response.body,
            email: 'taken'

          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlApiUsers()
            body:
              email: 'user@example.com'
              name: 'exampleuser'
              password: 'opensesame'
              rights: ''
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 422
          test.deepEqual response.body,
            name: 'taken'

          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlApiUsers()
            body:
              email: 'test@example.com'
              name: 'exampleuser'
              password: 'opensesame'
              rights: ''
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 422
          test.deepEqual response.body,
            email: 'taken'
            name: 'taken'

          shutdown()
        .then ->
          test.done()

  'with right canCreateUsers can create user with valid data': (test) ->
    app (
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
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanCreateUsers'
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
            method: 'POST'
            url: envStringBaseUrl + urlApiUsers()
            body:
              email: 'user@example.com'
              name: 'user'
              password: 'opensesame'
              rights: ''
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 201
          test.equal response.body.email, 'user@example.com'
          test.equal response.body.name, 'user'
          test.equal response.headers.location, urlApiUsers(response.body.id)
          shutdown()
        .then ->
          test.done()
