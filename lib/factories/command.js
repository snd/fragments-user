module.exports.command_users = function(APPLICATION) {
  return function(optionalId) {
    return APPLICATION(function(selectUser, firstUserWhereId, shutdown, omitPassword, _) {
      var promise;
      promise = optionalId ? firstUserWhereId(optionalId) : selectUser();
      return promise.bind({}).then(function(results) {
        return this.results = omitPassword(results);
      })["finally"](function() {
        return shutdown();
      }).then(function() {
        if (Array.isArray(this.results)) {
          console.log('users:');
          console.log(this.results);
        } else if (this.results) {
          console.log('user:');
          console.log(this.results);
        } else {
          console.log("no user with id `" + optionalId + "`");
        }
        console.log('OK');
        return this.results;
      });
    });
  };
};

module.exports.command_users.__help = "[optional-user-id] - show all users or just the user with `optional-user-id` (if given)";

module.exports.command_users_insert = function(APPLICATION) {
  return function(name, email, password) {
    if (!((name != null) && (email != null) && (password != null))) {
      console.log("Usage: ... " + module.exports.command_users_insert.__help);
      return;
    }
    return APPLICATION(function(insertUser, shutdown, omitPassword) {
      var user;
      user = {
        name: name,
        email: email,
        password: password,
        rights: ''
      };
      return insertUser(user).bind({}).then(function(inserted) {
        return this.inserted = omitPassword(inserted);
      })["finally"](function() {
        return shutdown();
      }).then(function() {
        console.log("inserted user with id `" + this.inserted.id + "`:");
        console.log(this.inserted);
        console.log('OK');
        return this.inserted;
      });
    });
  };
};

module.exports.command_users_insert.__help = '{name} {email} {password} - insert user';

module.exports.command_users_delete = function(APPLICATION) {
  return function(id) {
    if (id == null) {
      console.log("Usage: ... " + module.exports.command_users_delete.__help);
      return;
    }
    return APPLICATION(function(deleteUserWhereId, shutdown, omitPassword) {
      return deleteUserWhereId(id).bind({}).then(function(deletedUsers) {
        return this.user = omitPassword(deletedUsers[0]);
      })["finally"](function() {
        return shutdown();
      }).then(function() {
        if (this.user) {
          console.log("deleted user with id `" + id + "`:");
          console.log(this.user);
        } else {
          console.log("no user with id `" + id + "`");
        }
        console.log('OK');
        return this.user;
      });
    });
  };
};

module.exports.command_users_delete.__help = "{user-id} - delete user with `user-id`";

module.exports.command_rights = function(APPLICATION) {
  return function(id) {
    if (id == null) {
      console.log("Usage: ... " + module.exports.command_rights.__help);
      return;
    }
    return APPLICATION(function(firstUserWhereId, rightsStringToRightsArray, shutdown) {
      return firstUserWhereId(id).bind({}).then(function(user) {
        return this.user = user;
      })["finally"](function() {
        return shutdown();
      }).then(function() {
        var rights;
        if (this.user != null) {
          rights = rightsStringToRightsArray(this.user.rights);
          console.log("rights of user with id `" + id + "`:");
          console.log(rights);
          console.log('OK');
          return rights;
        } else {
          console.log("no user with id `" + id + "`");
          console.log('OK');
          return null;
        }
      });
    });
  };
};

module.exports.command_rights.__help = "{user-id} - list the rights of user with `user-id`";

module.exports.command_rights_insert = function(APPLICATION) {
  return function(id, right) {
    if (!((id != null) && (right != null))) {
      console.log("Usage: ... " + module.exports.command_rights_insert.__help);
      return;
    }
    return APPLICATION(function(grantUserRightWhereId, shutdown, omitPassword) {
      return grantUserRightWhereId(right, id).bind({}).then(function(user) {
        return this.user = omitPassword(user);
      })["finally"](function() {
        return shutdown();
      }).then(function() {
        if (this.user != null) {
          console.log("granted right `" + right + "` to user with id `" + id + "`:");
          console.log(this.user);
        } else {
          console.log("no user with id `" + id + "` or user already has right `" + right + "`");
        }
        console.log('OK');
        return this.user;
      });
    });
  };
};

module.exports.command_rights_insert.__help = "{user-id} {right} - grant `right` to user with `id`";

module.exports.command_rights_delete = function(APPLICATION) {
  return function(id, right) {
    if (!((id != null) && (right != null))) {
      console.log("Usage: ... " + module.exports.command_rights_delete.__help);
      return;
    }
    return APPLICATION(function(revokeUserRightWhereId, shutdown, omitPassword) {
      return revokeUserRightWhereId(right, id).bind({}).then(function(user) {
        return this.user = omitPassword(user);
      })["finally"](function() {
        return shutdown();
      }).then(function() {
        if (this.user != null) {
          console.log("removed right `" + right + "` from user with id `" + id + "`:");
          console.log(this.user);
        } else {
          console.log("no user with id `" + id + "` or user already doesn't have right `" + right + "`");
        }
        console.log('OK');
        return this.user;
      });
    });
  };
};

module.exports.command_rights_delete.__help = "{user-id} {right} - revoke `right` from user with `id`";

module.exports.command_fake_users = function(APPLICATION) {
  return function(count) {
    var printUsage;
    printUsage = function() {
      return console.log("Usage: ... " + module.exports.command_fake_users.__help);
    };
    if (count == null) {
      printUsage();
      return;
    }
    count = parseInt(count, 10);
    if (isNaN(count)) {
      printUsage();
      return;
    }
    return APPLICATION(function(insertFakeUsers, shutdown, omitPassword) {
      return insertFakeUsers(count).bind({}).then(function(users) {
        return this.users = omitPassword(users);
      })["finally"](function() {
        return shutdown();
      }).then(function() {
        console.log('OK');
        return this.users;
      });
    });
  };
};

module.exports.command_fake_users.__help = "{count} - insert `count` fake users";
