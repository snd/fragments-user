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

        command_serve()
      .then ->

        console.log 'unauthenticated'
        testHelperGet null, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        console.log 'authenticate'
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        console.log 'unprivileged'
        testHelperGet @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'wrong privilege'
        testHelperGrantUserRights 'operator', ['canGetUsers(100)']
      .then ->
        testHelperGet @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'single user privilege'
        testHelperGrantUserRights 'operator', ["canGetUsers(#{@other.id})"]
      .then ->
        testHelperGet @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, @other.id
        test.equal response.body.password, null

        console.log 'unprivileged'
        testHelperGet @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'privileged'
        testHelperGrantUserRights 'operator', ["canGetUsers()"]
      .then ->
        testHelperGet @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, @another.id
        test.equal response.body.password, null

        console.log 'privileged but not found'
        testHelperGet @token, urlApiUsers(100)
      .then (response) ->
        test.equal response.statusCode, 404

      .finally ->
        shutdown()
      .then ->
        test.done()
