module.exports.predicateToValidator = ->
  (predicate, error) ->
    (value) ->
      if predicate value
        null
      else
        error

# can work recursively
# TODO add second argument flag allowAdditionalKeys that is false by default
module.exports.schemaToValidator = (
) ->
  (schema) ->
    (data) ->
      errors = {}
      Object.keys(schema).forEach (key) ->
        validator = schema[key]
        unless 'function' is typeof validator
          throw new Error "validator must be a function but is #{typeof validator}"
        error = validator data[key]
        if error?
          errors[key] = error
      if Object.keys(errors).length is 0
        null
      else
        errors

module.exports.chainValidators = (
) ->
  (validators...) ->
    (value) ->
      for validator in validators
        errors = validator value
        if errors?
          return errors
      null

module.exports.existenceValidator = (
  isjs
  predicateToValidator
) ->
  predicateToValidator isjs.existy, 'must not be null or undefined'

module.exports.stringValidator = (
  isjs
  predicateToValidator
  chainValidators
  existenceValidator
) ->
  chainValidators(
    existenceValidator
    predicateToValidator(isjs.string, 'must be a string')
  )

module.exports.stringNotEmptyValidator = (
  isjs
  predicateToValidator
  chainValidators
  stringValidator
) ->
  chainValidators(
    stringValidator
    predicateToValidator(isjs.not.empty, 'must not be the empty string')
  )

module.exports.emailValidator = (
  isjs
  predicateToValidator
  chainValidators
  stringValidator
) ->
  chainValidators(
    stringValidator
    predicateToValidator(isjs.email, 'must be an email address')
  )

module.exports.stringMinLengthValidator = (
  predicateToValidator
  chainValidators
  stringNotEmptyValidator
) ->
  (min) ->
    predicate = (value) ->
      value.length >= min
    chainValidators(
      stringNotEmptyValidator
      predicateToValidator(predicate, "must be at least #{min} characters long")
    )

module.exports.optionalValidator = (
  isjs
) ->
  (validator) ->
    (value) ->
      if isjs.undefined value
        return
      validator value

module.exports.stringMinLengthValidator = (
  predicateToValidator
  chainValidators
  stringNotEmptyValidator
) ->
  (min) ->
    predicate = (value) ->
      value.length >= min
    chainValidators(
      stringNotEmptyValidator
      predicateToValidator(predicate, "must be at least #{min} characters long")
    )

module.exports.loginValidator = (
  schemaToValidator
  stringNotEmptyValidator
  stringMinLengthValidator
) ->
  schemaToValidator
    username: stringNotEmptyValidator
    password: stringMinLengthValidator(8)

module.exports.userInsertValidator = (
  schemaToValidator
  stringNotEmptyValidator
  stringMinLengthValidator
  stringValidator
  emailValidator
  Promise
  firstUserWhereName
  firstUserWhereEmail
) ->
  validator = schemaToValidator
    name: stringNotEmptyValidator
    password: stringMinLengthValidator(8)
    email: emailValidator
    # TODO replace by rights validator
    rights: stringValidator
  (user) ->
    Promise.resolve(validator user)
      .then (errors) ->
        if errors?.name?
          return errors
        firstUserWhereName(user.name).then (withSameName) ->
          if withSameName?
            errors ?= {}
            errors.name = 'taken'
          return errors
      .then (errors) ->
        if errors?.email?
          return errors
        firstUserWhereEmail(user.email).then (withSameEmail) ->
          if withSameEmail?
            errors ?= {}
            errors.email = 'taken'
          return errors

module.exports.selfUpdateValidator = (
  schemaToValidator
  optionalValidator
  stringNotEmptyValidator
  stringMinLengthValidator
  emailValidator
  firstUserWhereNameAndNotId
  firstUserWhereEmailAndNotId
) ->
  validator = schemaToValidator
    name: optionalValidator stringNotEmptyValidator
    password: optionalValidator stringMinLengthValidator(8)
    email: optionalValidator emailValidator
    rights: (value) ->
      if value?
        'you are not allowed to set your own rights'
  (user, id) ->
    Promise.resolve(validator user)
      .then (errors) ->
        if errors?.name?
          return errors
        firstUserWhereNameAndNotId(user.name, id).then (withSameName) ->
          if withSameName?
            errors ?= {}
            errors.name = 'taken'
          return errors
      .then (errors) ->
        if errors?.email?
          return errors
        firstUserWhereEmailAndNotId(user.email, id).then (withSameEmail) ->
          if withSameEmail?
            errors ?= {}
            errors.email = 'taken'
          return errors

module.exports.userUpdateValidator = (
  schemaToValidator
  optionalValidator
  stringNotEmptyValidator
  stringMinLengthValidator
  stringValidator
  emailValidator
  firstUserWhereNameAndNotId
  firstUserWhereEmailAndNotId
) ->
  validator = schemaToValidator
    name: optionalValidator stringNotEmptyValidator
    password: optionalValidator stringMinLengthValidator(8)
    email: optionalValidator emailValidator
    # TODO replace by rights validator
    rights: optionalValidator stringValidator
  (user, id) ->
    Promise.resolve(validator user)
      .then (errors) ->
        if errors?.name?
          return errors
        firstUserWhereNameAndNotId(user.name, id).then (withSameName) ->
          if withSameName?
            errors ?= {}
            errors.name = 'taken'
          return errors
      .then (errors) ->
        if errors?.email?
          return errors
        firstUserWhereEmailAndNotId(user.email, id).then (withSameEmail) ->
          if withSameEmail?
            errors ?= {}
            errors.email = 'taken'
          return errors
