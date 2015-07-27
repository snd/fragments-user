module.exports.testApiUserGet = (
  pgDropCreateMigrate
  testHelperInsertUser
  command_serve
  selectUser
  testHelperGet
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

        command_serve('cockpit')
      .then ->

        # unauthenticated
        testHelperGet null, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        # authenticate
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        # unprivileged
        testHelperGet @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        # wrong privilege
        testHelperGrantUserRights 'operator', ['canReadUsers(100)']
      .then ->
        testHelperGet @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        # single user privilege
        testHelperGrantUserRights 'operator', ["canReadUsers(#{@other.id})"]
      .then ->
        testHelperGet @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, @other.id
        test.equal response.body.password, null

        # unprivileged
        testHelperGet @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        # privileged
        testHelperGrantUserRights 'operator', ["canReadUsers()"]
      .then ->
        testHelperGet @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, @another.id
        test.equal response.body.password, null

        # privileged but not found
        testHelperGet @token, urlApiUsers(100)
      .then (response) ->
        test.equal response.statusCode, 404

      .finally ->
        shutdown()
      .then ->
        test.done()
