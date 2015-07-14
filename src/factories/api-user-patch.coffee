module.exports.apiUserPatch = (
  urlApiUsers
  PATCH
) ->
  PATCH urlApiUsers(':id'), (
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
