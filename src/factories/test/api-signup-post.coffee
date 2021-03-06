module.exports.testApiSignupPost = (
  pgDropCreateMigrate
  command_serve
  testHelperInsertUser
  testHelperPost
  testHelperGet
  urlApiSignup
  urlApiCurrentUser
  urlApiLogin
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

        console.log 'unprocessable'

        testHelperPost null, urlApiSignup(), null
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'must not be null or undefined'
          name: 'must not be null or undefined'
          password: 'must not be null or undefined'

        testHelperPost null, urlApiSignup(),
          email: 'dkjdlkf'
          name: ''
          password: 'aaa'
          rights: 'canAccessAllAndEverything # trying to escalate own rights should fail'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'must be an email address'
          name: 'must not be empty'
          password: 'must be at least 8 characters long'
          rights: 'you are not allowed to set your own rights'

        console.log 'unprocessable email taken'
        testHelperPost null, urlApiSignup(),
          email: 'operator@example.com'
          name: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'

        console.log 'unprocessable name taken'
        testHelperPost null, urlApiSignup(),
          email: 'other@example.com'
          name: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          name: 'taken'

        console.log 'unprocessable email and name taken'
        testHelperPost null, urlApiSignup(),
          email: 'operator@example.com'
          name: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          email: 'taken'
          name: 'taken'

        console.log 'success'
        testHelperPost null, urlApiSignup(),
          email: 'other@example.com'
          name: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 201
        test.notEqual response.body.token, null
        test.equal response.body.user.email, 'other@example.com'
        test.equal response.body.user.name, 'other'
        test.equal response.body.user.rights, ''
        test.equal response.body.user.password, null

        @token = response.body.token

        console.log 'a user that has signed up is logged in'
        testHelperGet @token, urlApiCurrentUser()
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'other@example.com'
        test.equal response.body.name, 'other'
        test.equal response.body.rights, ''
        test.equal response.body.password, null

        console.log 'a user that has signed up can login'
        testHelperPost null, urlApiLogin(),
          identifier: 'other'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.token, @token
        test.equal response.body.user.email, 'other@example.com'
        test.equal response.body.user.name, 'other'
        test.equal response.body.user.rights, ''
        test.ok not response.body.user.password?

      .finally ->
        shutdown()
      .then ->
        test.done()
