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
      .then (operator) ->
        this.operator = operator

        insertUser
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
          rights: ''
      .then (other) ->
        this.other = other

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

        # can update itself
        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(this.operator.id)
          body:
            email: 'operator@example.com'
            name: 'operator'
            password: 'topsecret'
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'operator@example.com'
        test.equal response.body.name, 'operator'
        test.equal response.body.password, null
        test.equal response.body.rights, 'canAccessCockpit\ncanUpdateUsers'

        # can update others
        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(this.other.id)
          body:
            email: 'other@example.com'
            name: 'other'
            password: 'topsecret'
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'other@example.com'
        test.equal response.body.name, 'other'
        test.equal response.body.password, null
        test.equal response.body.rights, ''

        shutdown()
      .then ->
        test.done()

module.exports.testApiUserPatchOkChange = (
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
      .then (operator) ->
        this.operator = operator

        insertUser
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
          rights: ''
      .then (other) ->
        this.other = other

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

        # can update itself
        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(this.operator.id)
          body:
            email: 'operatorchanged@example.com'
            name: 'operatorchanged'
            password: 'topsecretchanged'
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'operatorchanged@example.com'
        test.equal response.body.name, 'operatorchanged'
        test.equal response.body.password, null
        test.equal response.body.rights, 'canAccessCockpit\ncanUpdateUsers'

        # can update others
        requestPromise(
          method: 'PATCH'
          url: envStringBaseUrl + urlApiUsers(this.other.id)
          body:
            email: 'otherchanged@example.com'
            name: 'otherchanged'
            password: 'topsecretchanged'
          headers:
            authorization: "Bearer #{this.token}"
          json: true
        )
      .then ([response]) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'otherchanged@example.com'
        test.equal response.body.name, 'otherchanged'
        test.equal response.body.password, null
        test.equal response.body.rights, ''

        shutdown()
      .then ->
        test.done()
