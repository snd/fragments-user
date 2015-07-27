module.exports.testApiUsersPost = (
  pgDropCreateMigrate
  command_serve
  testHelperInsertUser
  testHelperPost
  testHelperLogin
  testHelperGrantUserRights
  urlApiUsers
  errorMessageForEndForbiddenTokenRequired
  errorMessageForEndForbiddenInsufficientRights
  shutdown
) ->
  (test) ->
    pgDropCreateMigrate()
      .bind({})
      .then ->
        testHelperInsertUser('operator', 'operator@example.com', 'topsecret')
      .then ->
        command_serve('cockpit')
      .then ->

        # unauthenticated
        testHelperPost null, urlApiUsers(),
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
          rights: ''
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        # authenticate
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        # unprivileged
        testHelperPost @token, urlApiUsers(),
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
          rights: ''
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        # continue with privileged
        testHelperGrantUserRights('operator', ['canCreateUsers'])
      .then ->

        # unprocessable
        testHelperPost @token, urlApiUsers(),
          email: 'dkjdlkf'
          name: ''
          password: ''
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'must not be empty'
          password: 'must not be empty'
          email: 'must be an email address'

        # unprocessable because taken

        testHelperPost @token, urlApiUsers(),
          email: 'operator@example.com'
          name: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'

        testHelperPost @token, urlApiUsers(),
          email: 'other@example.com'
          name: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'taken'

        testHelperPost @token, urlApiUsers(),
          email: 'operator@example.com'
          name: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'
          name: 'taken'

        # success

        testHelperPost @token, urlApiUsers(),
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 201
        test.equal response.body.email, 'other@example.com'
        test.equal response.body.name, 'other'
        test.equal response.body.rights, ''
        test.equal response.headers.location, urlApiUsers(response.body.id)

        # can create user with rights

        testHelperPost @token, urlApiUsers(),
          email: 'another@example.com'
          name: 'another'
          password: 'topsecret'
          rights: 'canCreateUsers'
      .then (response) ->
        test.equal response.statusCode, 201
        test.equal response.body.email, 'another@example.com'
        test.equal response.body.name, 'another'
        test.equal response.body.rights, 'canCreateUsers'
        test.equal response.headers.location, urlApiUsers(response.body.id)

      .finally ->
        shutdown()
      .then ->
        test.done()
