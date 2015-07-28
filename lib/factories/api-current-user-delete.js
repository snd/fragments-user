module.exports.apiCurrentUserDelete = function(DELETE, urlApiCurrentUser) {
  return DELETE(urlApiCurrentUser(), function(currentUser, endForbiddenTokenRequired, deleteUserWhereId, end) {
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    return deleteUserWhereId(currentUser.id).then(function() {
      return end();
    });
  });
};
