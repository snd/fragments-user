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

        # unauthenticated
        testHelperDelete null, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        # authenticate
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        # unprivileged
        testHelperDelete @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        # wrong privilege
        testHelperGrantUserRights 'operator', ['canDeleteUsers(100)']
      .then ->
        testHelperDelete @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        # single user privilege
        testHelperGrantUserRights 'operator', ["canDeleteUsers(#{@other.id})"]
      .then ->
        testHelperDelete @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body, null

        selectUser()
      .then (users) ->
        test.equal users.length, 2

        # unprivileged
        testHelperDelete @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        # privileged
        testHelperGrantUserRights 'operator', ["canDeleteUsers()"]
      .then ->
        testHelperDelete @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body, null

        selectUser()
      .then (users) ->
        test.equal users.length, 1

        # privileged but not found
        testHelperDelete @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 404

      .finally ->
        shutdown()
      .then ->
        test.done()
