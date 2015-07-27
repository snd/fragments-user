app = require '../app'

testKeys = [
  'testApiSignupPost'

  'testApiLoginPost'

  'testApiCurrentUserGet'
  'testApiCurrentUserPatch'
  'testApiCurrentUserDelete'

  'testApiUsersGet'
  'testApiUsersPost'

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
