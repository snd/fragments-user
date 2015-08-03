module.exports.validateLogin = (
  waechter
) ->
  waechter.schemaToValidator
    identifier: waechter.stringNotEmpty
    password: waechter.stringMinLength(8)

module.exports.idToSchemaUserTakenAsync = (
  firstUserWhereName
  firstUserWhereEmail
) ->
  (exceptId) ->
    name: (value) ->
      firstUserWhereName(value).then (user) ->
        unless user?
          return
        if exceptId? and user.id.toString() is exceptId.toString()
          return
        return 'taken'
    email: (value) ->
      firstUserWhereEmail(value).then (user) ->
        unless user?
          return
        if exceptId? and user.id.toString() is exceptId.toString()
          return
        return 'taken'

module.exports.schemaUserShared = (
  waechter
) ->
  name: waechter.stringNotEmpty
  password: waechter.stringMinLength(8)
  email: waechter.email

module.exports.schemaUserRightsForbidden = (
) ->
  rights: (value) ->
    if value?
      'you are not allowed to set your own rights'

module.exports.validateSignup = (
  waechter
  schemaUserShared
  schemaUserRightsForbidden
  idToSchemaUserTakenAsync
  _
) ->
  waechter.schemasToLazyAsyncValidator(
    _.merge({}, schemaUserShared, schemaUserRightsForbidden)
    idToSchemaUserTakenAsync()
  )

module.exports.validateUserInsert = (
  waechter
  schemaUserShared
  idToSchemaUserTakenAsync
  _
) ->
  waechter.schemasToLazyAsyncValidator(
    _.merge({}, schemaUserShared, {rights: waechter.undefinedOr(waechter.string)})
    idToSchemaUserTakenAsync()
  )

module.exports.validateSelfUpdate = (
  waechter
  schemaUserShared
  schemaUserRightsForbidden
  idToSchemaUserTakenAsync
  _
) ->
  (user, id) ->
    waechter.schemasToLazyAsyncValidator(
      _.merge({}, schemaUserShared, schemaUserRightsForbidden)
      idToSchemaUserTakenAsync(id)
    ) (user)

module.exports.validateUserUpdate = (
  waechter
  schemaUserShared
  idToSchemaUserTakenAsync
  _
) ->
  (user, id) ->
    waechter.schemasToLazyAsyncValidator(
      _.merge({}, schemaUserShared, {rights: waechter.undefinedOr(waechter.string)})
      idToSchemaUserTakenAsync(id)
    ) (user)
