app = require '../app'

# not critical. rough tests only.

module.exports =

  'users': (test) ->
    app (
      pgDropCreateMigrate
      command_users
      insertFakeUsers
      omitPassword
    ) ->
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertFakeUsers(3)
        .then (users) ->
          this.users = omitPassword users
          command_users()
        .then (users) ->
          test.deepEqual this.users, users
          test.done()

  'users {id}': (test) ->
    app (
      pgDropCreateMigrate
      insertFakeUsers
      command_users
      omitPassword
    ) ->
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertFakeUsers(1)
        .then (users) ->
          this.user = omitPassword users[0]
          test.ok this.user.id?
          command_users(this.user.id)
        .then (user) ->
          test.deepEqual this.user, user
          test.done()

  'users:insert': (test) ->
    app (
      pgDropCreateMigrate
      command_users_insert
    ) ->
      pgDropCreateMigrate()
        .then ->
          command_users_insert('test', 'test@example.com', 'opensesame')
        .then (user) ->
          test.ok user.id?
          test.equal user.name, 'test'
          test.equal user.email, 'test@example.com'
          test.ok not user.password?
          test.done()

  'users:delete': (test) ->
    app (
      pgDropCreateMigrate
      command_users_delete
      insertFakeUsers
      omitPassword
    ) ->
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertFakeUsers(1)
        .then (users) ->
          this.user = omitPassword users[0]
          test.ok this.user.id?
          command_users_delete(this.user.id)
        .then (user) ->
          test.deepEqual user, this.user
          test.done()

  'rights': (test) ->
    app (
      pgDropCreateMigrate
      command_rights
      insertFakeUsers
      grantUserRightWhereId
      omitPassword
    ) ->
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertFakeUsers(1)
        .then (users) ->
          this.user = omitPassword users[0]
          test.ok this.user.id?
          grantUserRightWhereId('canAccessCockpit', this.user.id)
        .then ->
          grantUserRightWhereId('canReadUsers', this.user.id)
        .then ->
          grantUserRightWhereId('canCreateUsers', this.user.id)
        .then ->
          command_rights(this.user.id)
        .then (rights) ->
          test.deepEqual rights, [
            'canAccessCockpit'
            'canReadUsers'
            'canCreateUsers'
          ]
          test.done()

  'rights': (test) ->
    app (
      pgDropCreateMigrate
      command_rights
      insertFakeUsers
      grantUserRightWhereId
      omitPassword
    ) ->
      pgDropCreateMigrate()
        .bind({})
        .then ->
          insertFakeUsers(1)
        .then (users) ->
          this.user = omitPassword users[0]
          test.ok this.user.id?
          grantUserRightWhereId('canAccessCockpit', this.user.id)
        .then ->
          grantUserRightWhereId('canReadUsers', this.user.id)
        .then ->
          grantUserRightWhereId('canCreateUsers', this.user.id)
        .then ->
          command_rights(this.user.id)
        .then (rights) ->
          test.deepEqual rights, [
            'canAccessCockpit'
            'canReadUsers'
            'canCreateUsers'
          ]
          test.done()

  'fake:users': (test) ->
    app (
      pgDropCreateMigrate
      command_fake_users
      selectUser
    ) ->
      pgDropCreateMigrate()
        .then ->
          command_fake_users(10)
        .then (fakeUsers) ->
          test.equal fakeUsers.length, 10
          test.done()
