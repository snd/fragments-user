module.exports.testApiCurrentUserGet = (
  pgDropCreateMigrate
  testHelperInsertUser
  testHelperLogin
  testHelperGet
  command_serve
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

        command_serve()
      .then ->

        testHelperGet(null, urlApiCurrentUser())
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token
        testHelperGet(@token, urlApiCurrentUser())
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'operator@example.com'
        test.equal response.body.name, 'operator'
        test.equal response.body.rights, ''
        test.equal response.body.password, null

      .finally ->
        shutdown()
      .then ->
        test.done()
