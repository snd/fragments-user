module.exports.omitPassword = function(_) {
  var omitPassword;
  omitPassword = function(userOrUsers) {
    if (Array.isArray(userOrUsers)) {
      return _.map(userOrUsers, omitPassword);
    } else {
      return _.omit(userOrUsers, 'password');
    }
  };
  return omitPassword;
};

module.exports.insertUser = function(userTable, hashPasswordIfPresent, _) {
  return function(user) {
    user = _.clone(user);
    if (user.rights == null) {
      user.rights = '';
    }
    return userTable.queueBeforeEach(hashPasswordIfPresent).allow('password', 'email', 'name', 'created_at', 'rights').returnFirst().insert(user);
  };
};

module.exports.firstUserWhereLogin = function(userTable, comparePasswordToHashed) {
  return function(login) {
    return userTable.where({
      $or: [
        {
          email: login.identifier
        }, {
          name: login.identifier
        }
      ]
    }).first().then(function(user) {
      if (user == null) {
        return null;
      }
      return comparePasswordToHashed(login.password, user.password).then(function(isEqual) {
        if (isEqual) {
          return user;
        } else {
          return null;
        }
      });
    });
  };
};

module.exports.updateUserWhereId = function(userTable, hashPasswordIfPresent) {
  return function(user, id) {
    return userTable.queueBeforeEach(hashPasswordIfPresent).allow('password', 'email', 'name', 'rights').where({
      id: id
    }).update(user);
  };
};

module.exports.grantUserRightWhereId = function(userTable, mesa) {
  return function(right, id) {
    return userTable.where({
      id: id
    }).where("rights NOT LIKE '%' || ? || '%'", right).returnFirst().unsafe().update({
      rights: mesa.raw("rights || '\n' || ?", right)
    });
  };
};

module.exports.revokeUserRightWhereId = function(userTable, mesa) {
  return function(right, id) {
    return userTable.where({
      id: id
    }).where("rights LIKE '%' || ? || '%'", right).returnFirst().unsafe().update({
      rights: mesa.raw("replace(rights, ?, '')", right)
    });
  };
};
