# post valid credentials to get a token.
# the token can then be passed in the authorization header:
# `Authorization:Bearer #{token}`.
# authorization header with valid token is needed for protected API endpoints.
module.exports.apiLogin = (
  POST
  urlApiLogin
  newJwt
  loginValidator
  firstUserWhereLogin
  _
) ->
  POST urlApiLogin(), (
    body
    endUnprocessableJSON
    endUnprocessableText
    endJSON
  ) ->
    errors = loginValidator body
    if errors?
      endUnprocessableJSON errors
      return
    firstUserWhereLogin(body).then (user) ->
      unless user?
        endUnprocessableText 'invalid username or password'
        return

      token = newJwt({id: user.id})
      endJSON
        token: token
        user: _.omit(user, 'password')
