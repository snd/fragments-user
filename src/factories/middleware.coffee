module.exports.cockpitAccessControlMiddleware = (
  MIDDLEWARE
) ->
  MIDDLEWARE (
    matchCurrentUrl
    urlApi
    canAccessCockpit
    endForbidden
    next
  ) ->
    if matchCurrentUrl(urlApi('*')) and not canAccessCockpit()
      endForbidden()
    else
      next()

module.exports.cockpit = (
  sequenz
  MIDDLEWARE
  commonMiddlewarePrelude
  cockpitAccessControlMiddleware

  apiLogin
  apiCurrentUserGet
  apiCurrentUserPatch
  apiUsersGet
  apiUsersPost
  apiUserGet
  apiUserPatch
  apiUserDelete
) ->
  sequenz [
    commonMiddlewarePrelude

    apiLogin

    # everything except the login action requires user to have right to access cockpit
    cockpitAccessControlMiddleware

    apiCurrentUserGet
    apiCurrentUserPatch
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
