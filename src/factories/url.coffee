module.exports.flexibleUrl = ->
  (prefix) ->
    (suffix) ->
      if suffix then prefix + '/' + suffix else prefix

################################################################################
# api

module.exports.urlApi = (
  flexibleUrl
) ->
  flexibleUrl '/api'

module.exports.urlApiLogin = (
  urlApi
) ->
  ->
    urlApi('login')

module.exports.urlApiSignup = (
  urlApi
) ->
  ->
    urlApi('signup')

module.exports.urlApiCurrentUser = (
  urlApi
) ->
  ->
    urlApi('me')

module.exports.urlApiUsers = (
  flexibleUrl
  urlApi
) ->
  flexibleUrl urlApi('users')
