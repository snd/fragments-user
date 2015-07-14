module.exports.apiUserGet = (
  urlApiUsers
  GET
) ->
  GET urlApiUsers(':id'), (
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
