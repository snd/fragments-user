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

module.exports.testHelperRequest = (
  requestPromise
  envStringBaseUrl
) ->
  (token, method, path, body) ->
    # console.log
    #   token: token
    #   method: method
    #   path: path
    #   body: body

    options =
      method: method
      url: envStringBaseUrl + path
      json: true
    if body?
      options.body = body
    if token?
      options.headers =
        authorization: "Bearer #{token}"
    requestPromise(options).then ([response]) ->
      response

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
