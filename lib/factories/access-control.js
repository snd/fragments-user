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

module.exports.currentUserHasRight = function(currentRightsObject, rightsObjectHasRight) {
  return function() {
    var args, right;
    right = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    return rightsObjectHasRight.apply(null, [currentRightsObject, right].concat(slice.call(args)));
  };
};

module.exports.currentUserRightArgs = function(currentRightsObject) {
  return function(right) {
    return currentRightsObject[right];
  };
};
