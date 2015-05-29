module.exports.flexibleUrl = ->
  (prefix) ->
    (suffix) ->
      if suffix then prefix + '/' + suffix else prefix

################################################################################
# api

module.exports.urlCockpitApi = (
  flexibleUrl
) ->
  flexibleUrl '/api/cockpit'

module.exports.urlCockpitApiLogin = (
  urlCockpitApi
) ->
  ->
    urlCockpitApi('login')

module.exports.urlCockpitApiMe = (
  urlCockpitApi
) ->
  ->
    urlCockpitApi('me')

module.exports.urlCockpitApiUsers = (
  flexibleUrl
  urlCockpitApi
) ->
  flexibleUrl urlCockpitApi('users')

################################################################################
# single page app

module.exports.urlCockpit = (
  flexibleUrl
) ->
  flexibleUrl '/cockpit'

module.exports.urlPatternCockpit = (
  Pattern
  urlCockpit
) ->
  new Pattern urlCockpit()
