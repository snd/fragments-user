var slice = [].slice;

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

module.exports.rightsObjectHasRight = function(tryCoerceNumber, _) {
  return function() {
    var args, right, rightArgsArray, rightsObject;
    rightsObject = arguments[0], right = arguments[1], args = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    args = args.map(tryCoerceNumber);
    rightArgsArray = rightsObject[right];
    if (rightArgsArray == null) {
      return false;
    }
    return _.some(rightArgsArray, function(rightArgs) {
      return _.isEqual(args, rightArgs);
    });
  };
};
