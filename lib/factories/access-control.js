var slice = [].slice;

module.exports.currentUser = function(token, firstUserWhereId, _) {
  var id;
  id = token != null ? token.id : void 0;
  if (id == null) {
    return null;
  }
  return firstUserWhereId(id).then(function(user) {
    if (user == null) {
      return null;
    }
    return _.omit(user, 'password');
  });
};

module.exports.rightsStringToRightsArray = function(_) {
  return function(string) {
    var results;
    results = string.split('\n').map(function(x) {
      return x.trim();
    }).filter(function(x) {
      return x !== '';
    }).filter(function(x) {
      return x.charAt(0) !== '#';
    });
    return _.uniq(results);
  };
};

module.exports.rightsArrayToRightsObject = function(parseRight) {
  return function(rightsArray) {
    var rightsObject;
    rightsObject = {};
    rightsArray.forEach(function(string) {
      var right;
      right = parseRight(string);
      if (right != null) {
        if (rightsObject[right.name] == null) {
          rightsObject[right.name] = [];
        }
        return rightsObject[right.name].push(right.args);
      }
    });
    return rightsObject;
  };
};

module.exports.rightsStringToRightsObject = function(rightsStringToRightsArray, rightsArrayToRightsObject) {
  return function(string) {
    return rightsArrayToRightsObject(rightsStringToRightsArray(string));
  };
};

module.exports.currentRightsArray = function(currentUser, rightsStringToRightsArray) {
  if (currentUser == null) {
    return [];
  }
  return rightsStringToRightsArray(currentUser.rights);
};

module.exports.currentRightsObject = function(currentUser, rightsStringToRightsObject) {
  if (currentUser == null) {
    return {};
  }
  return rightsStringToRightsObject(currentUser.rights);
};

module.exports.tryCoerceNumber = function() {
  return function(value) {
    var maybeNumber;
    if ('string' !== typeof value) {
      return value;
    }
    maybeNumber = parseInt(value, 10);
    if (isNaN(maybeNumber)) {
      return value;
    }
    if (maybeNumber.toString() !== value) {
      return value;
    }
    return maybeNumber;
  };
};

module.exports.currentUserHasRight = function(currentRightsObject, isjs, tryCoerceNumber, _) {
  return function() {
    var args, right, rightArgsArray;
    right = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    args = args.map(tryCoerceNumber);
    rightArgsArray = currentRightsObject[right];
    if (rightArgsArray == null) {
      return false;
    }
    return _.some(rightArgsArray, function(rightArgs) {
      return _.isEqual(args, rightArgs);
    });
  };
};

module.exports.currentUserRightArgs = function(currentRightsObject) {
  return function(right) {
    return currentRightsObject[right];
  };
};
