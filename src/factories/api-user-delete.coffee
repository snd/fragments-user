module.exports.apiUserDelete = (
  urlApiUsers
  DELETE
) ->
  DELETE urlApiUsers(':id'), (
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
