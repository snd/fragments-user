module.exports.testApiLoginPost = (
  pgDropCreateMigrate
  command_serve
  testHelperPost
  testHelperGet
  testHelperInsertUser
  shutdown
  urlApiLogin
  urlApiCurrentUser
  console
) ->
  (test) ->
    pgDropCreateMigrate()
      .bind({})
      .then ->

        command_serve()
      .then ->

        console.log 'unprocessable no body'
        testHelperPost null, urlApiLogin(), null
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          identifier: 'must not be null or undefined'
          password: 'must not be null or undefined'

        console.log 'unprocessable'
        testHelperPost null, urlApiLogin(),
          identifier: 'operator'
          password: 'top'
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          password: 'must be at least 8 characters long'

        console.log 'not found for email or username'
        testHelperPost null, urlApiLogin(),
          identifier: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 422
        test.equal response.body, 'invalid identifier (username or email) or password'

        console.log 'insert a user so we can login'
        testHelperInsertUser('operator', 'operator@example.com', 'topsecret')
      .then ->

        console.log 'wrong password'
        testHelperPost null, urlApiLogin(),
          identifier: 'operator'
          password: 'opensesame'
      .then (response) ->
        test.equal response.statusCode, 422
        test.equal response.body, 'invalid identifier (username or email) or password'

        console.log 'login with email'
        testHelperPost null, urlApiLogin(),
          identifier: 'operator@example.com'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 200
        test.notEqual response.body.token, null
        test.equal response.body.user.email, 'operator@example.com'
        test.equal response.body.user.name, 'operator'
        test.equal response.body.user.rights, ''
        test.equal response.body.user.password, null

        console.log 'token is valid'
        testHelperGet response.body.token, urlApiCurrentUser()
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.email, 'operator@example.com'
        test.equal response.body.name, 'operator'
        test.equal response.body.rights, ''
        test.equal response.body.password, null

        console.log 'login with name'
        testHelperPost null, urlApiLogin(),
          identifier: 'operator'
          password: 'topsecret'
      .then (response) ->
        test.equal response.statusCode, 200
        test.notEqual response.body.token, null
        test.equal response.body.user.email, 'operator@example.com'
        test.equal response.body.user.name, 'operator'
        test.equal response.body.user.rights, ''
        test.equal response.body.user.password, null

        console.log 'token is valid'
        testHelperGet response.body.token, urlApiCurrentUser()
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
