// Generated by CoffeeScript 1.9.3
module.exports.apiUserGet = function(urlApiUsers, GET) {
  return GET(urlApiUsers(':id'), function(currentUser, endForbiddenTokenRequired, endForbiddenInsufficientRights, firstUserWhereId, params, endJSON, end404, canReadUsers, omitPassword) {
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    if (!(canReadUsers() || canReadUsers(params.id))) {
      return endForbiddenInsufficientRights();
    }
    return firstUserWhereId(params.id).then(function(user) {
      if (user != null) {
        return endJSON(omitPassword(user));
      } else {
        return end404();
      }
    });
  });
};