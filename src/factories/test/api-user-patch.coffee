module.exports.testApiUserPatch = (
  pgDropCreateMigrate
  testHelperInsertUser
  command_serve
  selectUser
  testHelperPatch
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
        testHelperPatch null, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        console.log 'authenticate'
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        console.log 'unprivileged'
        testHelperPatch @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'wrong privilege'
        testHelperGrantUserRights 'operator', ['canPatchUsers(100)']
      .then ->
        testHelperPatch @token, urlApiUsers(@other.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'continue with single user privilege'
        testHelperGrantUserRights 'operator', ["canPatchUsers(#{@other.id})"]
      .then ->

        console.log 'unprocessable'
        testHelperPatch @token, urlApiUsers(@other.id),
          email: 'dkjdlkf'
          name: ''
          password: ''
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'must not be empty'
          password: 'must not be empty'
          email: 'must be an email address'

        console.log 'unprocessable because taken'
        testHelperPatch @token, urlApiUsers(@other.id),
          email: 'operator@example.com'
          name: 'other'
          password: 'topsecret'
          rights: 'canAccessAllAndEverything'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'

        testHelperPatch @token, urlApiUsers(@other.id),
          email: 'other@example.com'
          name: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'taken'

        testHelperPatch @token, urlApiUsers(@other.id),
          email: 'operator@example.com'
          name: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'
          name: 'taken'

        console.log 'success with same data'
        testHelperPatch @token, urlApiUsers(@other.id),
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, @other.id
        test.equal response.body.password, null
        test.equal response.body.name, 'other'
        test.equal response.body.email, 'other@example.com'
        test.equal response.body.rights, ''

        console.log 'success with different data'
        testHelperPatch @token, urlApiUsers(@other.id),
          email: 'otherchanged@example.com'
          name: 'otherchanged'
          password: 'topsecret'
          rights: 'canAccessEverything'
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, @other.id
        test.equal response.body.password, null
        test.equal response.body.name, 'otherchanged'
        test.equal response.body.email, 'otherchanged@example.com'
        test.equal response.body.rights, 'canAccessEverything'

        console.log 'unprivileged'
        testHelperPatch @token, urlApiUsers(@another.id)
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'privileged'
        testHelperGrantUserRights 'operator', ["canPatchUsers()"]
      .then ->

        testHelperPatch @token, urlApiUsers(@another.id),
          email: 'another@example.com'
          name: 'another'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.id, @another.id
        test.equal response.body.password, null
        test.equal response.body.name, 'another'
        test.equal response.body.email, 'another@example.com'
        test.equal response.body.rights, ''

        console.log 'privileged but not found'
        testHelperPatch @token, urlApiUsers(100),
          email: 'yetanother@example.com'
          name: 'yetanother'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 404

      .finally ->
        shutdown()
      .then ->
        test.done()
