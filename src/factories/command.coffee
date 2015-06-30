module.exports.command_users = (
  APPLICATION
) ->
  (optionalId) ->
    APPLICATION (
      selectUser
      firstUserWhereId
      shutdown
      omitPassword
      _
    ) ->
      promise = if optionalId then firstUserWhereId(optionalId) else selectUser()
      promise
        .bind({})
        .then (results) ->
          this.results = omitPassword results
        .finally ->
          shutdown()
        .then ->
          if Array.isArray this.results
            console.log 'users:'
            console.log this.results
          else if this.results
            console.log 'user:'
            console.log this.results
          else
            console.log "no user with id `#{optionalId}`"
          console.log 'OK'
          return this.results
module.exports.command_users.__help = "[optional-user-id] - show all users or just the user with `optional-user-id` (if given)"

module.exports.command_users_insert = (
  APPLICATION
) ->
  (name, email, password) ->
    unless name? and email? and password?
      console.log "Usage: ... #{module.exports.command_users_insert.__help}"
      return
    APPLICATION (
      insertUser
      shutdown
      omitPassword
    ) ->
      user =
        name: name
        email: email
        password: password
        rights: ''
      insertUser(user)
        .bind({})
        .then (inserted) ->
          this.inserted = omitPassword inserted
        .finally ->
          shutdown()
        .then ->
          console.log "inserted user with id `#{this.inserted.id}`:"
          console.log this.inserted
          console.log 'OK'
          return this.inserted
module.exports.command_users_insert.__help = '{name} {email} {password} - insert user'

module.exports.command_users_delete = (
  APPLICATION
) ->
  (id) ->
    unless id?
      console.log "Usage: ... #{module.exports.command_users_delete.__help}"
      return
    APPLICATION (
      deleteUserWhereId
      shutdown
      omitPassword
    ) ->
      deleteUserWhereId(id)
        .bind({})
        .then (deletedUsers) ->
          this.user = omitPassword deletedUsers[0]
        .finally ->
          shutdown()
        .then ->
          if this.user
            console.log "deleted user with id `#{id}`:"
            console.log this.user
          else
            console.log "no user with id `#{id}`"
          console.log 'OK'
          return this.user
module.exports.command_users_delete.__help = "{user-id} - delete user with `user-id`"

module.exports.command_rights = (
  APPLICATION
) ->
  (id) ->
    unless id?
      console.log "Usage: ... #{module.exports.command_rights.__help}"
      return
    APPLICATION (
      firstUserWhereId
      rightsStringToRightsArray
      shutdown
    ) ->
      firstUserWhereId(id)
        .bind({})
        .then (user) ->
          this.user = user
        .finally ->
          shutdown()
        .then ->
          if this.user?
            rights = rightsStringToRightsArray this.user.rights
            console.log "rights of user with id `#{id}`:"
            console.log rights
            console.log 'OK'
            return rights
          else
            console.log "no user with id `#{id}`"
            console.log 'OK'
            return null
module.exports.command_rights.__help = "{user-id} - list the rights of user with `user-id`"

module.exports.command_rights_insert = (
  APPLICATION
) ->
  (id, right) ->
    unless id? and right?
      console.log "Usage: ... #{module.exports.command_rights_insert.__help}"
      return

    APPLICATION (
      grantUserRightWhereId
      shutdown
      omitPassword
    ) ->
      grantUserRightWhereId(right, id)
        .bind({})
        .then (user) ->
          this.user = omitPassword user
        .finally ->
          shutdown()
        .then ->
          if this.user?
            console.log "granted right `#{right}` to user with id `#{id}`:"
            console.log this.user
          else
            console.log "no user with id `#{id}` or user already has right `#{right}`"
          console.log 'OK'
          return this.user
module.exports.command_rights_insert.__help = "{user-id} {right} - grant `right` to user with `id`"

module.exports.command_rights_delete = (
  APPLICATION
) ->
  (id, right) ->
    unless id? and right?
      console.log "Usage: ... #{module.exports.command_rights_delete.__help}"
      return

    APPLICATION (
      revokeUserRightWhereId
      shutdown
      omitPassword
    ) ->
      revokeUserRightWhereId(right, id)
        .bind({})
        .then (user) ->
          this.user = omitPassword user
        .finally ->
          shutdown()
        .then ->
          if this.user?
            console.log "removed right `#{right}` from user with id `#{id}`:"
            console.log this.user
          else
            console.log "no user with id `#{id}` or user already doesn't have right `#{right}`"
          console.log 'OK'
          return this.user
module.exports.command_rights_delete.__help = "{user-id} {right} - revoke `right` from user with `id`"

module.exports.command_fake_users = (
  APPLICATION
) ->
  (count) ->
    printUsage = ->
      console.log "Usage: ... #{module.exports.command_fake_users.__help}"
    unless count?
      printUsage()
      return
    count = parseInt count, 10
    if isNaN count
      printUsage()
      return

    APPLICATION (
      insertFakeUsers
      shutdown
      omitPassword
    ) ->
      insertFakeUsers(count)
        .bind({})
        .then (users) ->
          this.users = omitPassword users
        .finally ->
          shutdown()
        .then ->
          console.log 'OK'
          return this.users
module.exports.command_fake_users.__help = "{count} - insert `count` fake users"
