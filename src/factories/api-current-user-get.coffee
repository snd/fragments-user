module.exports.apiCurrentUserGet = (
  GET
  urlApiCurrentUser
) ->
  GET urlApiCurrentUser(), (
    currentUser
    endJSON
    endForbidden
  ) ->
    unless currentUser?
      return endForbidden()
    endJSON currentUser
