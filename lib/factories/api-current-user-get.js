module.exports.apiCurrentUserGet = function(GET, urlApiCurrentUser) {
  return GET(urlApiCurrentUser(), function(currentUser, endJSON, endForbiddenTokenRequired) {
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    return endJSON(currentUser);
  });
};
