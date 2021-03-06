module.exports.apiCurrentUserPatch = function(PATCH, urlApiCurrentUser) {
  return PATCH(urlApiCurrentUser(), function(currentUser, body, omitPassword, endForbiddenTokenRequired, validateSelfUpdate, endUnprocessableJSON, endJSON, updateUserWhereId) {
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    return validateSelfUpdate(body, currentUser.id).then(function(errors) {
      if (errors != null) {
        return endUnprocessableJSON(errors);
      }
      delete body.rights;
      return updateUserWhereId(body, currentUser.id).then(function(updated) {
        return endJSON(omitPassword(updated[0]));
      });
    });
  });
};
