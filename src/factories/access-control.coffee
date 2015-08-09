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

module.exports.rightsStringToRightsArray = (
  _
) ->
  (string) ->
    results = string
      .split('\n')
      # remove leading and trailing whitespace
      .map((x) -> x.trim())
      # remove empty lines
      .filter((x) -> x isnt '')
      # remove comments
      .filter((x) -> x.charAt(0) isnt '#')
    # remove duplicates
    return _.uniq results

module.exports.rightsArrayToRightsObject = (
  parseRight
) ->
  (rightsArray) ->
    rightsObject = {}
    rightsArray.forEach (string) ->
      right = parseRight string
      # we ignore invalid permission strings right now
      if right?
        unless rightsObject[right.name]?
          rightsObject[right.name] = []
        rightsObject[right.name].push right.args
    return rightsObject

module.exports.rightsStringToRightsObject = (
  rightsStringToRightsArray
  rightsArrayToRightsObject
) ->
  (string) ->
    rightsArrayToRightsObject rightsStringToRightsArray string

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

module.exports.tryCoerceNumber = (
) ->
  (value) ->
    unless 'string' is typeof value
      return value
    maybeNumber = parseInt value, 10
    if isNaN maybeNumber
      return value
    if maybeNumber.toString() isnt value
      return value
    return maybeNumber

module.exports.currentUserHasRight = (
  currentRightsObject
  isjs
  tryCoerceNumber
  _
) ->
  (right, args...) ->
    # filteredArgs = _.filter args, isjs.not.undefined

    args = args.map tryCoerceNumber
    rightArgsArray = currentRightsObject[right]
    # console.log 'currentUserHasRight',
    #   right: right
    #   args: args
    #   currentRightsObject: currentRightsObject
    #   rightArgsArray: rightArgsArray
    unless rightArgsArray?
      return false
    _.some rightArgsArray, (rightArgs) ->
      # console.log 'equal',
      #   right: right
      #   args: args
      #   rightArgs: rightArgs
      #   equal: _.isEqual args, rightArgs
      _.isEqual args, rightArgs

module.exports.currentUserRightArgs = (
  currentRightsObject
) ->
  (right) ->
    currentRightsObject[right]
