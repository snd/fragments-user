app = require '../app'

testKeys = [
  'testApiLoginUnprocessableNoBody'
  'testApiLoginUnprocessableInvalidPassword'
  'testApiLoginUnprocessableUserNotFound'
  'testApiLoginUnprocessableWrongPassword'
  'testApiLoginOk'

  'testApiCurrentUserGetForbidden'
  'testApiCurrentUserGetOk'

  'testApiCurrentUserPatchForbidden'
  'testApiCurrentUserPatchUnprocessable'
  'testApiCurrentUserPatchUnprocessableTaken'
  'testApiCurrentUserPatchOkNoChange'
  'testApiCurrentUserPatchOkChange'

  'testApiUsersGetForbidden'
  'testApiUsersGetOkAll'
  'testApiUsersGetUnprocessable'
  'testApiUsersGetOkFiltered'

  'testApiUserGetForbidden'
  'testApiUserGetOk'
  'testApiUserGetSingleRight'
  'testApiUserGetNotFound'

  'testApiUsersPostForbidden'
  'testApiUsersPostUnprocessable'
  'testApiUsersPostUnprocessableTaken'
  'testApiUsersPostOk'

  'testApiUserDeleteForbidden'
  'testApiUserDeleteOk'
]

testKeys.forEach (testKey) ->
  module.exports[testKey] = (test) ->
    factory = (testFn) ->
      testFn test
    factory.__inject = [testKey]
    app factory
