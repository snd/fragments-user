module.exports.testApiUserDelete = (
  pgDropCreateMigrate
  testHelperInsertUser
  command_serve
  selectUser
  testHelperDelete
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

        testHelperInsertUser('other', 'other@example.com', 'topsecret')
      .then (user) ->
        test.notEqual user.id, null
        @other = user

        testHelperInsertUser('another', 'another@example.com', 'topsecret')
      .then (user) ->
        test.notEqual user.id, null
        @another = user

        selectUser()
      .then (users) ->
        test.equal users.length, 3

        command_serve()
      .then ->

        console.log 'unauthenticated'
        testHelperDelete null, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        console.log 'authenticate'
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        console.log 'unprivileged'
        testHelperDelete @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'wrong privilege'
        testHelperGrantUserRights 'operator', ['canDeleteUsers(100)']
      .then ->
        testHelperDelete @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'single user privilege'
        testHelperGrantUserRights 'operator', ["canDeleteUsers(#{@other.id})"]
      .then ->
        testHelperDelete @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body, ''

        selectUser()
      .then (users) ->
        test.equal users.length, 2

        console.log 'unprivileged'
        testHelperDelete @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'privileged'
        testHelperGrantUserRights 'operator', ["canDeleteUsers()"]
      .then ->
        testHelperDelete @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body, ''

        selectUser()
      .then (users) ->
        test.equal users.length, 1

        console.log 'privileged but not found'
        testHelperDelete @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 404

      .finally ->
        shutdown()
      .then ->
        test.done()
