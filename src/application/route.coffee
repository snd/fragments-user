# post valid credentials to get a token.
# the token can then be passed in the authorization header:
# `Authorization:Bearer #{token}`.
# authorization header with valid token is needed for protected API endpoints.
module.exports.route_cockpitApiLogin = (
  POST
  urlCockpitApiLogin
  newJwt
  loginValidator
  firstUserWhereLogin
  _
) ->
  POST urlCockpitApiLogin(), (
    body
    endUnprocessableJSON
    endUnprocessableText
    endJSON
  ) ->
    errors = loginValidator body
    if errors?
      endUnprocessableJSON errors
      return
    firstUserWhereLogin(body).then (user) ->
      unless user?
        endUnprocessableText 'invalid username or password'
        return

      token = newJwt({id: user.id})
      endJSON
        token: token
        user: _.omit(user, 'password')

module.exports.route_cockpitApiMe = (
  sequenz
  GET
  PATCH
  urlCockpitApiMe
) ->
  sequenz [
    GET urlCockpitApiMe(), (
      currentUser
      endJSON
      endForbidden
    ) ->
      unless currentUser?
        return endForbidden()
      endJSON currentUser

    PATCH urlCockpitApiMe(), (
      currentUser
      body
      omitPassword
      selfUpdateValidator
      endUnprocessableJSON
      endJSON
      canAccessCockpit
      updateUserWhereId
    ) ->
      unless canAccessCockpit()
        return endForbidden()
      selfUpdateValidator(body, currentUser.id).then (errors) ->
        if errors?
          return endUnprocessableJSON errors
        delete body.rights
        updateUserWhereId(body, currentUser.id).then (updated) ->
          endJSON omitPassword updated
  ]

module.exports.route_cockpitApiUsers = (
  sequenz
  urlCockpitApiUsers
  GET
  POST
  PUT
  PATCH
  DELETE
) ->
  sequenz [
    GET urlCockpitApiUsers(), (
      userTable
      query
      siv
      endJSON
      endForbidden
      endUnprocessableJSON
      canReadUsers
      omitPassword
      _
    ) ->
      unless canReadUsers()
        return endForbidden()

      sql = userTable
      sql = siv.limit(sql, query)
      sql = siv.offset(sql, query)
      sql = siv.order(sql, query,
        # newest first by default
        order: 'created_at'
        asc: false
        allow: [
          'created_at'
          'id'
          'name'
          'email'
        ]
      )
      sql = siv.integer(sql, query, 'id')
      sql = siv.string(sql, query, 'email')
      sql = siv.string(sql, query, 'name')
      sql = siv.date(sql, query, 'created_at')

      if siv.isError sql
        endUnprocessableJSON
          query: query
          errors: sql.json
      else
        sql.find().then (users) ->
          endJSON omitPassword users

    GET urlCockpitApiUsers(':id'), (
      firstUserWhereId
      endForbidden
      params
      endJSON
      end404
      canReadUsers
      omitPassword
    ) ->
      unless canReadUsers() or canReadUsers(params.id)
        return endForbidden()
      firstUserWhereId(params.id).then (user) ->
        unless user?
          return end404()
        endJSON omitPassword user

    POST urlCockpitApiUsers(), (
      canCreateUsers
      endForbidden
      setHeaderLocation
      endCreatedJSON
      userInsertValidator
      endUnprocessableJSON
      body
      omitPassword
    ) ->
      unless canCreateUsers()
        return endForbidden()
      userInsertValidator(body).then (errors) ->
        if errors?
          return endUnprocessableJSON errors
        insertUser(body).then (inserted) ->
          setHeaderLocation urlCockpitApiUsers(inserted.id)
          endCreatedJSON omitPassword inserted

    PATCH urlCockpitApiUsers(':id'), (
      canUpdateUsers
      endForbidden
      userUpdateValidator
      endUnprocessableJSON
      updateUserWhereId
      omitPassword
    ) ->
      unless canUpdateUsers() or canUpdateUsers(params.id)
        return endForbidden()
      userUpdateValidator(body, params.id).then (errors) ->
        if errors?
          return endUnprocessableJSON errors
        updateUserWhereId(body, params.id).then (updated) ->
          endJSON omitPassword updated

    DELETE urlCockpitApiUsers(':id'), (
      canDeleteUsers
      endForbidden
      deleteUserWhereId
      params
      end
    ) ->
      unless canDeleteUsers() or canDeleteUsers(params.id)
        return endForbidden()
      deleteUserWhereId(params.id).then ->
        end()
  ]
