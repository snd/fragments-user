module.exports.cockpitAccessControlMiddleware = (
  MIDDLEWARE
) ->
  MIDDLEWARE (
    matchCurrentUrl
    urlCockpitApi
    canAccessCockpit
    endForbidden
    next
  ) ->
    if matchCurrentUrl(urlCockpitApi('*')) and not canAccessCockpit()
      endForbidden()
    else
      next()

module.exports.cockpit = (
  sequenz
  MIDDLEWARE
  commonMiddlewarePrelude
  cockpitAccessControlMiddleware
  route_cockpitApiLogin
  route_cockpitApiMe
  route_cockpitApiUsers
) ->
  sequenz [
    commonMiddlewarePrelude

    route_cockpitApiLogin

    # everything except route_cockpitApiLogin requires user to have right to access cockpit
    cockpitAccessControlMiddleware

    route_cockpitApiMe
    route_cockpitApiUsers

    # when no other route matches respond with 404
    MIDDLEWARE (
      end404
    ) ->
      end404()
  ]
