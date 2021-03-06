module.exports.testApiCurrentUserDelete = (
  pgDropCreateMigrate
  testHelperInsertUser
  command_serve
  testHelperLogin
  testHelperDelete
  testHelperGet
  testHelperPost
  urlApiCurrentUser
  urlApiLogin
  selectUser
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

        console.log 'unauthenticated'
        testHelperDelete null, urlApiCurrentUser()
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        console.log 'authenticate'
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        console.log 'delete'
        testHelperDelete @token, urlApiCurrentUser()
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body, ''

        console.log 'cant get current user after delete'
        testHelperGet(@token, urlApiCurrentUser())
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        console.log 'cant login after delete'
        testHelperPost null, urlApiLogin(),
          identifier: 'operator@example.com'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.equal response.body, 'invalid identifier (username or email) or password'

        selectUser()
      .then (users) ->
        test.equal users.length, 0

      .finally ->
        shutdown()
      .then ->
        test.done()
