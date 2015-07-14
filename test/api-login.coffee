app = require '../app'

module.exports =

  'login validation failure because no body': (test) ->
    app (
      command_serve
      shutdown
      envStringBaseUrl
      urlApiLogin
      requestPromise
    ) ->
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

  'login validation failure because invalid password': (test) ->
    app (
      command_serve
      shutdown
      envStringBaseUrl
      urlApiLogin
      requestPromise
    ) ->
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

  'login invalid username or password because nonexisting user': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlApiLogin
      requestPromise
    ) ->
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

  'login invalid username or password because wrong password': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlApiLogin
      requestPromise
      insertUser
    ) ->
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

  'can login with either username or email': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlApiLogin
      requestPromise
      insertUser
    ) ->
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
