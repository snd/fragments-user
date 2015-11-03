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

module.exports.rightsObjectHasRight = (
  tryCoerceNumber
  _
) ->
  (rightsObject, right, args...) ->
    args = args.map tryCoerceNumber
    rightArgsArray = rightsObject[right]
    unless rightArgsArray?
      return false
    _.some rightArgsArray, (rightArgs) ->
      _.isEqual args, rightArgs
