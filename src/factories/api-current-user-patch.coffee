module.exports.apiCurrentUserPatch = (
  PATCH
  urlApiCurrentUser
) ->
  PATCH urlApiCurrentUser(), (
    currentUser
    body
    omitPassword
    selfUpdateValidator
    endUnprocessableJSON
    endJSON
    canAccessCockpit
    updateUserWhereId
  ) ->
    unless canAccessCockpit()
      return endForbidden()
    selfUpdateValidator(body, currentUser.id).then (errors) ->
      if errors?
        return endUnprocessableJSON errors
      delete body.rights
      updateUserWhereId(body, currentUser.id).then (updated) ->
        endJSON omitPassword updated
