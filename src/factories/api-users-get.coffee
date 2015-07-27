module.exports.apiUsersGet = (
  urlApiUsers
  GET
) ->
  GET urlApiUsers(), (
    userTable
    query
    siv
    endJSON
    endForbidden
    endForbiddenTokenRequired
    endForbiddenInsufficientRights
    endUnprocessableJSON
    canReadUsers
    omitPassword
    currentUser
    _
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    unless canReadUsers()
      return endForbiddenInsufficientRights()

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
