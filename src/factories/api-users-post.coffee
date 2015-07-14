module.exports.apiUsersPost = (
  urlApiUsers
  POST
) ->
  POST urlApiUsers(), (
    canCreateUsers
    endForbidden
    setHeaderLocation
    endCreatedJSON
    userInsertValidator
    insertUser
    endUnprocessableJSON
    urlApiUsers
    body
    omitPassword
  ) ->
    unless canCreateUsers()
      return endForbidden()
    userInsertValidator(body).then (errors) ->
      if errors?
        return endUnprocessableJSON errors
      insertUser(body).then (inserted) ->
        setHeaderLocation urlApiUsers(inserted.id)
        endCreatedJSON omitPassword inserted
