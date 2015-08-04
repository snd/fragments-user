module.exports.testApiUsersGet = (
  pgDropCreateMigrate
  command_serve
  testHelperInsertUser
  testHelperGrantUserRights
  testHelperGet
  testHelperLogin
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
        testHelperInsertUser('a', 'a@yahoo.com', 'topsecret')
      .then ->
        testHelperInsertUser('b', 'b@gmail.com', 'topsecret')
      .then ->
        testHelperInsertUser('c', 'c@yahoo.com', 'topsecret')
      .then ->

        command_serve()
      .then ->

        console.log 'unauthenticated'
        testHelperGet null, urlApiUsers()
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenTokenRequired

        console.log 'authenticate'
        testHelperLogin(test, 'operator', 'topsecret')
      .then (token) ->
        @token = token

        console.log 'unprivileged'
        testHelperGet @token, urlApiUsers()
      .then (response) ->
        test.equal response.statusCode, 403
        test.equal response.body, errorMessageForEndForbiddenInsufficientRights

        console.log 'make privileged'
        testHelperGrantUserRights 'operator', ['canGetUsers']
      .then ->

        console.log 'unprocessable'

        querystring = [
          'limit=a'
          'offset=a'
          'order=cash'
          'asc=bla'
          'where[id][gt]=ab'
        ].join('&')

        testHelperGet @token, urlApiUsers() + '?' + querystring
      .then (response) ->
        test.equal response.statusCode, 422
        test.deepEqual response.body,
          query:
            limit: 'a',
            offset: 'a'
            order: 'cash'
            asc: 'bla'
            where: { id: { gt: 'ab' } }
          errors:
            limit: 'must be an integer',
            offset: 'must be an integer',
            order: 'ordering by this column is not allowed',
            asc: 'must be either the string `true` or the string `false`',
            where: { id: { gt: 'must be parsable as an integer' } }

        console.log 'success all'
        testHelperGet @token, urlApiUsers()
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.length, 4

        console.log 'success filtered'

        querystring = [
          'where[email][contains]=yahoo'
          'order=name'
          'asc=false'
        ].join('&')

        testHelperGet @token, urlApiUsers() + '?' + querystring
      .then (response) ->
        test.equal response.statusCode, 200
        test.equal response.body.length, 2
        test.equal response.body[0].name, 'c'
        test.equal response.body[1].name, 'a'

      .finally ->
        shutdown()
      .then ->
        test.done()
