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
