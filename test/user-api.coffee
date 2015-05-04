app = require '../app'

module.exports =

  'cannot GET /api/cockpit/users without right canReadUsers': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiUsers()
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'can GET /api/cockpit/users with right canReadUsers': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiUsers()
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

  'error when GET /api/cockpit/users with invalid query parameters': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiUsers() + '?' + querystring
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

  'can filter GET /api/cockpit/users with query parameters': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
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
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiUsers() + '?' + querystring
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

  'cannot GET /api/cockpit/users/2 without right canReadUsers': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
      requestPromise
      insertFakeUsers
      insertUser
    ) ->
      pgDropCreateMigrate()
        .bind({})
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
            url: envStringBaseUrl + urlCockpitApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          this.token = response.body.token

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlCockpitApiUsers(2)
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'can GET /api/cockpit/users/2 with right canReadUsers': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
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
          insertFakeUsers(3)
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiLogin()
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
            url: envStringBaseUrl + urlCockpitApiUsers(2)
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.body.id, 2

          shutdown()
        .then ->
          test.done()

  'can GET /api/cockpit/users/2 with right canReadUsers(2) but cannot GET /api/cockpit/users/3': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
      requestPromise
      insertFakeUsers
      insertUser
    ) ->
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanReadUsers(2)'
        .then ->
          insertFakeUsers(3)
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          this.token = response.body.token

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlCockpitApiUsers(2)
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          test.equal response.body.id, 2

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlCockpitApiUsers(3)
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'cannot GET /api/cockpit/users/2 when it doesnt exist': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
      requestPromise
      insertFakeUsers
      insertUser
    ) ->
      pgDropCreateMigrate()
        .bind({})
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
            url: envStringBaseUrl + urlCockpitApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          this.token = response.body.token

          requestPromise(
            method: 'GET'
            url: envStringBaseUrl + urlCockpitApiUsers(2)
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 404

          shutdown()
        .then ->
          test.done()

  'cannot POST /api/cockpit/users without right canCreateUsers': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
      requestPromise
      insertFakeUsers
      insertUser
    ) ->
      pgDropCreateMigrate()
        .bind({})
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
            url: envStringBaseUrl + urlCockpitApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          this.token = response.body.token

          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiUsers()
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 403

          shutdown()
        .then ->
          test.done()

  'with right canCreateUsers can POST invalid data /api/cockpit/users': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
      requestPromise
      insertFakeUsers
      insertUser
    ) ->
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertUser
            email: 'test@example.com'
            name: 'exampleuser'
            password: 'topsecret'
            rights: 'canAccessCockpit\ncanCreateUsers'
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          this.token = response.body.token

          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiUsers()
            body:
              email: 'dkjdlkf'
              name: ''
              password: ''
            headers:
              authorization: "Bearer #{this.token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 422
          test.deepEqual response.body,
            name: 'must not be the empty string'
            password: 'must not be the empty string'
            email: 'must be an email address'
            rights: 'must not be null or undefined'

          shutdown()
        .then ->
          test.done()

  'with right canDeleteUsers can DELETE /api/cockpit/users/2': (test) ->
    app (
      command_serve
      pgDropCreateMigrate
      shutdown
      envStringBaseUrl
      urlCockpitApiLogin
      urlCockpitApiUsers
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
            rights: 'canAccessCockpit\ncanDeleteUsers'
        .then ->
          insertFakeUsers(3)
        .then ->
          command_serve('cockpit')
        .then ->
          requestPromise(
            method: 'POST'
            url: envStringBaseUrl + urlCockpitApiLogin()
            json: true
            body:
              username: 'exampleuser'
              password: 'topsecret'
          )
        .then ([response]) ->
          test.equal response.statusCode, 200
          token = response.body.token

          requestPromise(
            method: 'DELETE'
            url: envStringBaseUrl + urlCockpitApiUsers(2)
            headers:
              authorization: "Bearer #{token}"
            json: true
          )
        .then ([response]) ->
          test.equal response.statusCode, 200

          # TODO test that user is actually deleted
          shutdown()
        .then ->
          test.done()
