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
  isjs
  _
) ->
  (right, args...) ->
    filteredArgs = _.filter args, isjs.not.undefined
    result = if filteredArgs.length is 0
      currentRightsObject[right]? or currentRightsObject[right + '()']?
    else
      currentRightsObject[right + '(' + filteredArgs.join(',') + ')']?
    return result

module.exports.canAccessCockpit = (
  currentUserHasRight
) ->
  ->
    currentUserHasRight 'canAccessCockpit'

module.exports.canReadUsers = (
  currentUserHasRight
) ->
  (id) ->
    currentUserHasRight 'canReadUsers', id

module.exports.canCreateUsers = (
  currentUserHasRight
) ->
  ->
    currentUserHasRight 'canCreateUsers'

module.exports.canUpdateUsers = (
  currentUserHasRight
) ->
  (id) ->
    currentUserHasRight 'canUpdateUsers', id

module.exports.canDeleteUsers = (
  currentUserHasRight
) ->
  (id) ->
    currentUserHasRight 'canDeleteUsers', id
