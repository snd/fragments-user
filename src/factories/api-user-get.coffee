module.exports.apiUserGet = (
  urlApiUsers
  GET
) ->
  GET urlApiUsers(':id'), (
    currentUser
    endForbiddenTokenRequired
    endForbiddenInsufficientRights
    firstUserWhereId
    params
    endJSON
    end404
    canGetUsers
    omitPassword
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    unless canGetUsers() or canGetUsers(params.id)
      return endForbiddenInsufficientRights()
    firstUserWhereId(params.id).then (user) ->
      if user?
        endJSON omitPassword user
      else
        end404()
