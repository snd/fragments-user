module.exports.validateLogin = function(waechter) {
  return waechter.schemaToValidator({
    identifier: waechter.stringNotEmpty,
    password: waechter.stringMinLength(8)
  });
};

module.exports.idToSchemaUserTakenAsync = function(firstUserWhereName, firstUserWhereEmail) {
  return function(exceptId) {
    return {
      name: function(value) {
        return firstUserWhereName(value).then(function(user) {
          if (user == null) {
            return;
          }
          if ((exceptId != null) && user.id.toString() === exceptId.toString()) {
            return;
          }
          return 'taken';
        });
      },
      email: function(value) {
        return firstUserWhereEmail(value).then(function(user) {
          if (user == null) {
            return;
          }
          if ((exceptId != null) && user.id.toString() === exceptId.toString()) {
            return;
          }
          return 'taken';
        });
      }
    };
  };
};

module.exports.schemaUserShared = function(waechter) {
  return {
    name: waechter.stringNotEmpty,
    password: waechter.stringMinLength(8),
    email: waechter.email
  };
};

module.exports.schemaUserRightsForbidden = function() {
  return {
    rights: function(value) {
      if (value != null) {
        return 'you are not allowed to set your own rights';
      }
    }
  };
};

module.exports.validateSignup = function(waechter, schemaUserShared, schemaUserRightsForbidden, idToSchemaUserTakenAsync, _) {
  return waechter.schemasToLazyAsyncValidator(_.merge({}, schemaUserShared, schemaUserRightsForbidden), idToSchemaUserTakenAsync());
};

module.exports.validateUserInsert = function(waechter, schemaUserShared, idToSchemaUserTakenAsync, _) {
  return waechter.schemasToLazyAsyncValidator(_.merge({}, schemaUserShared, {
    rights: waechter.undefinedOr(waechter.string)
  }), idToSchemaUserTakenAsync());
};

module.exports.validateSelfUpdate = function(waechter, schemaUserShared, schemaUserRightsForbidden, idToSchemaUserTakenAsync, _) {
  return function(user, id) {
    return waechter.schemasToLazyAsyncValidator(_.merge({}, schemaUserShared, schemaUserRightsForbidden), idToSchemaUserTakenAsync(id))(user);
  };
};

module.exports.validateUserUpdate = function(waechter, schemaUserShared, idToSchemaUserTakenAsync, _) {
  return function(user, id) {
    return waechter.schemasToLazyAsyncValidator(_.merge({}, schemaUserShared, {
      rights: waechter.undefinedOr(waechter.string)
    }), idToSchemaUserTakenAsync(id))(user);
  };
};
