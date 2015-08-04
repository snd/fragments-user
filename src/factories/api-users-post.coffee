module.exports.apiUsersPost = (
  urlApiUsers
  POST
) ->
  POST urlApiUsers(), (
    canPostUsers
    endForbiddenTokenRequired
    endForbiddenInsufficientRights
    setHeaderLocation
    endCreatedJSON
    validateUserInsert
    insertUser
    endUnprocessableJSON
    urlApiUsers
    body
    omitPassword
    currentUser
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    unless canPostUsers()
      return endForbiddenInsufficientRights()
    validateUserInsert(body).then (errors) ->
      if errors?
        return endUnprocessableJSON errors
      insertUser(body).then (inserted) ->
        setHeaderLocation urlApiUsers(inserted.id)
        endCreatedJSON omitPassword inserted
