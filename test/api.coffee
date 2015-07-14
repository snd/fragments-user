app = require '../app'

testKeys = [

  # login

  'testApiLoginUnprocessableNoBody'
  'testApiLoginUnprocessableInvalidPassword'
  'testApiLoginUnprocessableUserNotFound'
  'testApiLoginUnprocessableWrongPassword'
  'testApiLoginOk'

  # current user

  'testApiCurrentUserGetForbidden'
  'testApiCurrentUserGetOk'

  'testApiCurrentUserPatchForbidden'
  'testApiCurrentUserPatchUnprocessable'
  'testApiCurrentUserPatchUnprocessableTaken'
  'testApiCurrentUserPatchOkNoChange'
  'testApiCurrentUserPatchOkChange'

  # users

  'testApiUsersGetForbidden'
  'testApiUsersGetOkAll'
  'testApiUsersGetUnprocessable'
  'testApiUsersGetOkFiltered'

  'testApiUsersPostForbidden'
  'testApiUsersPostUnprocessable'
  'testApiUsersPostUnprocessableTaken'
  'testApiUsersPostOk'

  # user

  'testApiUserGetForbidden'
  'testApiUserGetOk'
  'testApiUserGetSingleRight'
  'testApiUserGetNotFound'

  'testApiUserPatchForbidden'
  'testApiUserPatchUnprocessable'
  'testApiUserPatchUnprocessableTaken'
  'testApiUserPatchOkNoChange'
  'testApiUserPatchOkChange'

  'testApiUserDeleteForbidden'
  'testApiUserDeleteOk'
]

testKeys.forEach (testKey) ->
  module.exports[testKey] = (test) ->
    factory = (testFn) ->
      testFn test
    factory.__inject = [testKey]
    app factory
