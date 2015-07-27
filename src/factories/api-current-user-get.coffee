module.exports.apiCurrentUserGet = (
  GET
  urlApiCurrentUser
) ->
  GET urlApiCurrentUser(), (
    currentUser
    endJSON
    endForbiddenTokenRequired
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    endJSON currentUser
