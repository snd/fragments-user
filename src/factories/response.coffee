module.exports.errorMessageForEndForbiddenTokenRequired = (
  urlApiLogin
) ->
  """Forbidden.

Please provide a valid access token in the HTTP Authorization header as shown here:
`Authorization:Bearer your-token-goes-here`

# How do i get a token ?
In the response when logging in with valid credentials.
The response body will be JSON and the token can be found in the property `token`.

# How do i log in ?
Send a POST request to #{urlApiLogin()}.
include the params (either as JSON or formencoded)
`identifier` (either email or username) and `password`.

# I have provided a token but i still get `Forbidden`:
Your token is no longer valid (or it never was).
Log in again to get a new valid token.
"""

module.exports.endForbiddenTokenRequired = (
  endForbidden
  errorMessageForEndForbiddenTokenRequired
) ->
  ->
    endForbidden errorMessageForEndForbiddenTokenRequired

module.exports.errorMessageForEndForbiddenInsufficientRights = (
) ->
  """Forbidden.

You don't have the right to do that.
"""

module.exports.endForbiddenInsufficientRights = (
  endForbidden
  errorMessageForEndForbiddenInsufficientRights
) ->
  ->
    endForbidden errorMessageForEndForbiddenInsufficientRights
