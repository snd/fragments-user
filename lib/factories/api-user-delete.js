module.exports.apiUserDelete = function(urlApiUsers, DELETE) {
  return DELETE(urlApiUsers(':id'), function(currentUser, canDeleteUsers, endForbiddenTokenRequired, endForbiddenInsufficientRights, deleteUserWhereId, params, end404, end) {
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    if (!(canDeleteUsers() || canDeleteUsers(params.id))) {
      return endForbiddenInsufficientRights();
    }
    return deleteUserWhereId(params.id).then(function(deleted) {
      if (deleted.length === 0) {
        return end404();
      } else {
        return end();
      }
    });
  });
};
