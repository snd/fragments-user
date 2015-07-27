module.exports.apiCurrentUserPatch = (
  PATCH
  urlApiCurrentUser
) ->
  PATCH urlApiCurrentUser(), (
    currentUser
    body
    omitPassword
    endForbiddenTokenRequired
    validateSelfUpdate
    endUnprocessableJSON
    endJSON
    updateUserWhereId
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    validateSelfUpdate(body, currentUser.id).then (errors) ->
      if errors?
        return endUnprocessableJSON errors
      delete body.rights
      updateUserWhereId(body, currentUser.id).then (updated) ->
        endJSON omitPassword updated[0]
