module.exports.apiCurrentUserDelete = (
  DELETE
  urlApiCurrentUser
) ->
  DELETE urlApiCurrentUser(), (
    currentUser
    endForbiddenTokenRequired
    deleteUserWhereId
    end
  ) ->
    unless currentUser?
      return endForbiddenTokenRequired()
    # TODO we might just flag user as deleted here instead of deleting
    deleteUserWhereId(currentUser.id).then ->
      end()
