module.exports.testApiCurrentUserPatch = (
  pgDropCreateMigrate
  testHelperInsertUser
  command_serve
  testHelperPatch
  testHelperLogin
  urlApiCurrentUser
  errorMessageForEndForbiddenTokenRequired
  shutdown
) ->
  (test) ->
    pgDropCreateMigrate()
      .bind({})

      .then ->
        testHelperInsertUser('operator', 'operator@example.com', 'topsecret')
      .then ->
        testHelperInsertUser('other', 'other@example.com', 'topsecret')

        command_serve()
      .then ->

        # unauthenticated
        testHelperPatch null, urlApiCurrentUser(),
          name: 'operatorchanged'
          email: 'emailchanged'
          password: 'topsecretchanged'
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        # authenticate
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        # unprocessable
        testHelperPatch @token, urlApiCurrentUser(),
          email: 'dkjdlkf'
          name: ''
          password: ''
          rights: 'canAccessAllAndEverything # trying to escalate own rights should fail'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'must not be empty'
          password: 'must not be empty'
          email: 'must be an email address'
          rights: 'you are not allowed to set your own rights'

        # unprocessable because taken

        testHelperPatch @token, urlApiCurrentUser(),
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'taken'
          email: 'taken'

        testHelperPatch @token, urlApiCurrentUser(),
          email: 'other@example.com'
          name: 'another'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'

        testHelperPatch @token, urlApiCurrentUser(),
          email: 'another@example.com'
          name: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'taken'

        # success but not change
        testHelperPatch @token, urlApiCurrentUser(),
          email: 'operator@example.com'
          name: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'operator@example.com'
        test.equal response.body.name, 'operator'
        test.equal response.body.rights, ''
        test.equal response.body.password, null

        # success with change
        testHelperPatch @token, urlApiCurrentUser(),
          email: 'operatorchanged@example.com'
          name: 'operatorchanged'
          password: 'topsecretchanged'
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'operatorchanged@example.com'
        test.equal response.body.name, 'operatorchanged'
        test.equal response.body.rights, ''
        test.equal response.body.password, null

      .finally ->
        shutdown()
      .then ->
        test.done()
