app = require '../app'

testKeys = [
  'testApiSignupPost'

  # login

  'testApiLoginPost'

  # current user

  'testApiCurrentUserGet'
  'testApiCurrentUserPatch'

  'testApiCurrentUserDelete'

  # user collection

  'testApiUsersGet'
  'testApiUsersPost'

  # user record

  'testApiUserGet'
  'testApiUserPatch'
  'testApiUserDelete'
]

testKeys.forEach (testKey) ->
  module.exports[testKey] = (test) ->
    factory = (testFn) ->
      testFn test
    factory.__inject = [testKey]
    app factory
