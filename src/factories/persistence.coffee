module.exports.omitPassword = (_) ->
  omitPassword = (userOrUsers) ->
    if Array.isArray userOrUsers
      _.map userOrUsers, omitPassword
    else
      _.omit userOrUsers, 'password'
  return omitPassword

module.exports.insertUser = (
  userTable
  hashPasswordIfPresent
  _
) ->
  (user) ->
    user = _.clone user
    user.rights ?= ''
    userTable
      .queueBeforeEach(hashPasswordIfPresent)
      .allow(
        'password'
        'email'
        'name'
        'created_at'
        'rights'
      )
      .returnFirst()
      .insert(user)

module.exports.firstUserWhereLogin = (
  userTable
  comparePasswordToHashed
) ->
  (login) ->
    userTable
      .where($or: [
        {email: login.identifier}
        {name: login.identifier}
      ])
      .first()
      .then (user) ->
        unless user?
          return null

        comparePasswordToHashed(login.password, user.password).then (isEqual) ->
          if isEqual
            user
          else
            null

module.exports.updateUserWhereId = (
  userTable
  hashPasswordIfPresent
) ->
  (user, id) ->
    userTable
      .queueBeforeEach(hashPasswordIfPresent)
      .allow(
        'password'
        'email'
        'name'
        'rights'
      )
      .where(id: id)
      .update(user)

module.exports.grantUserRightWhereId = (
  userTable
  mesa
) ->
  (right, id) ->
    userTable
      .where(id: id)
      # dont add the same right twice
      .where("rights NOT LIKE '%' || ? || '%'", right)
      .returnFirst()
      .unsafe()
      .update(
        rights: mesa.raw("rights || '\n' || ?", right)
      )

module.exports.revokeUserRightWhereId = (
  userTable
  mesa
) ->
  (right, id) ->
    userTable
      .where(id: id)
      # dont try to remove right the user doesnt have
      .where("rights LIKE '%' || ? || '%'", right)
      .returnFirst()
      .unsafe()
      .update(
        rights: mesa.raw("replace(rights, ?, '')", right)
      )
