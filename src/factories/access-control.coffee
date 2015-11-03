module.exports.currentUser = (
  token
  firstUserWhereId
  _
) ->
  id = token?.id
  unless id?
    return null

  firstUserWhereId(id).then (user) ->
    unless user?
      return null
    _.omit user, 'password'

module.exports.currentRightsArray = (
  currentUser
  rightsStringToRightsArray
) ->
  unless currentUser?
    return []

  rightsStringToRightsArray currentUser.rights

module.exports.currentRightsObject = (
  currentUser
  rightsStringToRightsObject
) ->
  unless currentUser?
    return {}

  rightsStringToRightsObject currentUser.rights

module.exports.currentUserHasRight = (
  currentRightsObject
  rightsObjectHasRight
) ->
  (right, args...) ->
    rightsObjectHasRight currentRightsObject, right, args...

module.exports.currentUserRightArgs = (
  currentRightsObject
) ->
  (right) ->
    currentRightsObject[right]
