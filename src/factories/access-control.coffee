module.exports.rightsStringToRightsArray = (
) ->
  (string) ->
    string
      .split('\n')
      # remove leading and trailing whitespace
      .map((x) -> x.trim())
      # remove empty lines
      .filter((x) -> x isnt '')
      # remove comments
      .filter((x) -> x.charAt(0) isnt '#')

module.exports.rightsArrayToRightsObject = (
) ->
  (array) ->
    result = {}
    array.forEach (x) ->
      result[x] = true
    return result

module.exports.rightsStringToRightsObject = (
  rightsStringToRightsArray
  rightsArrayToRightsObject
) ->
  (string) ->
    rightsArrayToRightsObject rightsStringToRightsArray string

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
