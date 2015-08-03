module.exports.testHelperInsertUser = (
  insertUser
) ->
  (name, email, password) ->
    insertUser
      name: name
      email: email
      password: password
      rights: ''

module.exports.testHelperGrantUserRights = (
  Promise
  firstUserWhereName
  grantUserRightWhereId
) ->
  (name, rights) ->
    firstUserWhereName(name).then (user) ->
      unless user?
        return Promise.reject new Error "no user named `#{name}`"
      Promise.all(rights).each (right) ->
        grantUserRightWhereId(right, user.id)

module.exports.testHelperRevokeUserRights = (
  Promise
  firstUserWhereName
  revokeUserRightWhereId
) ->
  (name, rights) ->
    firstUserWhereName(name).then (user) ->
      unless user?
        return Promise.reject new Error "no user named `#{name}`"
      Promise.all(rights).each (right) ->
        revokeUserRightWhereId(right, user.id)

module.exports.testHelperRequest = (
  got
  envStringBaseUrl
  Promise
) ->
  (token, method, path, body) ->
    # console.log
    #   token: token
    #   method: method
    #   path: path
    #   body: body

    url = envStringBaseUrl + path
    # console.log url
    options =
      method: method
    if body?
      options.body = body
    if token?
      options.headers =
        authorization: "Bearer #{token}"
    Promise.resolve(got(url, options))
      .catch got.HTTPError, (err) ->
        return err.response
      .then (res) ->
        contentType = res.headers['content-type']
        if contentType? and 0 is contentType.indexOf 'application/json'
          res.body = JSON.parse res.body.toString()
        return res

module.exports.testHelperGet = (
  testHelperRequest
) ->
  (token, path) ->
    testHelperRequest token, 'GET', path

module.exports.testHelperPatch = (
  testHelperRequest
) ->
  (token, path, body) ->
    testHelperRequest token, 'PATCH', path, body

module.exports.testHelperPost = (
  testHelperRequest
) ->
  (token, path, body) ->
    testHelperRequest token, 'POST', path, body

module.exports.testHelperDelete = (
  testHelperRequest
) ->
  (token, path) ->
    testHelperRequest token, 'DELETE', path

module.exports.testHelperLogin = (
  testHelperPost
  urlApiLogin
) ->
  (test, identifier, password) ->
    testHelperPost(null, urlApiLogin(),
      identifier: identifier
      password: password
    )
      .then (response) ->
        test.equal response.statusCode, 200
        test.notEqual response.body.token, null
        return response.body.token
