module.exports.cockpit = (
  sequenz
  MIDDLEWARE
  commonMiddlewarePrelude

  apiSignup
  apiLogin
  apiCurrentUserGet
  apiCurrentUserPatch
  apiCurrentUserDelete
  apiUsersGet
  apiUsersPost
  apiUserGet
  apiUserPatch
  apiUserDelete
) ->
  sequenz [
    commonMiddlewarePrelude

    # if you don't want to allow signup just don't include this route
    apiSignup

    apiLogin

    apiCurrentUserGet
    apiCurrentUserPatch
    # if you don't want to allow users to delete themselves just don't include this route
    apiCurrentUserDelete

    apiUsersGet
    apiUsersPost

    apiUserGet
    apiUserPatch
    apiUserDelete

    # when no other route matches respond with 404
    MIDDLEWARE (
      end404
    ) ->
      end404()
  ]
