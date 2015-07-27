module.exports.apiUserDelete = (
  urlApiUsers
  DELETE
) ->
  DELETE urlApiUsers(':id'), (
    currentUser
    canDeleteUsers
    endForbiddenTokenRequired
    endForbiddenInsufficientRights
    deleteUserWhereId
    params
    end404
    end
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    unless canDeleteUsers() or canDeleteUsers(params.id)
      return endForbiddenInsufficientRights()
    deleteUserWhereId(params.id).then (deleted) ->
      if deleted.length is 0
        end404()
      else
        end()
