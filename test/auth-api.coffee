app = require '../app'

module.exports =

  'login validation failure because no body': (test) ->
    app (
      command_serve
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      requestPromise
    ) ->
      command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiLogin()
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
      urlCockpitApiLogin
      requestPromise
    ) ->
      command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiLogin()
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
      urlCockpitApiLogin
      requestPromise
    ) ->
      pgDropCreateMigrate()
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiLogin()
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
      urlCockpitApiLogin
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
      urlCockpitApiLogin
      urlCockpitApiMe
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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


  'cant GET /api/cockpit/me without sufficient rights': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiMe
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiMe()
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'can GET /api/cockpit/me with sufficient rights': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiMe
      requestPromise
      insertUser
    ) ->
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiMe()
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

  'cannot PATCH /api/cockpit/me without right canAccessCockpit': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiMe
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiMe()
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'cannot PATCH /api/cockpit/me with invalid data': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiMe
      requestPromise
      insertUser
    ) ->
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiMe()
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

  'cannot PATCH /api/cockpit/me with name and/or email of another user': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiMe
      requestPromise
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiMe()
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
            url: envStringBaseUrl + urlCockpitApiMe()
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
            url: envStringBaseUrl + urlCockpitApiMe()
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

  'can PATCH /api/cockpit/me with identical data': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiMe
      requestPromise
      insertUser
    ) ->
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiMe()
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

  'can PATCH /api/cockpit/me with different data': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiMe
      requestPromise
      insertUser
    ) ->
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiMe()
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
