module.exports.apiUserPatch = (
  urlApiUsers
  PATCH
) ->
  PATCH urlApiUsers(':id'), (
    canPatchUsers
    currentUser
    endForbiddenTokenRequired
    endForbiddenInsufficientRights
    end404
    validateUserUpdate
    endUnprocessableJSON
    updateUserWhereId
    omitPassword
    params
    body
    endJSON
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    unless canPatchUsers() or canPatchUsers(params.id)
      return endForbiddenInsufficientRights()
    validateUserUpdate(body, params.id).then (errors) ->
      if errors?
        return endUnprocessableJSON errors
      updateUserWhereId(body, params.id).then (updated) ->
        if updated.length isnt 1
          end404()
        else
          endJSON omitPassword updated[0]
