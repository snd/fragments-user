app = require '../app'

module.exports =

  'can not filter users without right canReadUsers': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlApiLogin
      urlApiUsers
      requestPromise
      insertUser
    ) ->
      pgDropCreateMigrate()
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit'
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          token = response.body.token

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlApiUsers()
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'can filter users with right canReadUsers': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlApiLogin
      urlApiUsers
      requestPromise
      insertFakeUsers
      insertUser
    ) ->
      pgDropCreateMigrate()
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanReadUsers'
        .then ->
          insertFakeUsers(10)
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          token = response.body.token

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlApiUsers()
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.body.length, 11

          shutdown()
        .then ->
          test.done()

  'error when filtering users with invalid query parameters': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlApiLogin
      urlApiUsers
      requestPromise
      insertUser
    ) ->
      pgDropCreateMigrate()
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanReadUsers'
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          token = response.body.token

          querystring = [
            'limit=a'
            'offset=a'
            'order=cash'
            'asc=bla'
            'where[id][gt]=ab'
          ].join('&')

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlApiUsers() + '?' + querystring
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
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

          shutdown()
        .then ->
          test.done()

  'can filter users with query parameters': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlApiLogin
      urlApiUsers
      requestPromise
      insertUser
    ) ->
      pgDropCreateMigrate()
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanReadUsers'
        .then ->
          insertUser
            email: 'a@yahoo.com'
            name: 'a'
            password: 'topsecret'
            rights: ''
        .then ->
          insertUser
            email: 'b@gmail.com'
            name: 'b'
            password: 'topsecret'
            rights: ''
        .then ->
          insertUser
            email: 'c@yahoo.de'
            name: 'c'
            password: 'topsecret'
            rights: ''
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          token = response.body.token

          querystring = [
            'where[email][contains]=yahoo'
            'order=name'
            'asc=false'
          ].join('&')

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlApiUsers() + '?' + querystring
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.body.length, 2
          test.equal response.body[0].name, 'c'
          test.equal response.body[1].name, 'a'

          shutdown()
        .then ->
          test.done()
