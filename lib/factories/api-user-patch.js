module.exports.apiUserPatch = function(urlApiUsers, PATCH) {
  return PATCH(urlApiUsers(':id'), function(canPatchUsers, currentUser, endForbiddenTokenRequired, endForbiddenInsufficientRights, end404, validateUserUpdate, endUnprocessableJSON, updateUserWhereId, omitPassword, params, body, endJSON) {
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    if (!(canPatchUsers() || canPatchUsers(params.id))) {
      return endForbiddenInsufficientRights();
    }
    return validateUserUpdate(body, params.id).then(function(errors) {
      if (errors != null) {
        return endUnprocessableJSON(errors);
      }
      return updateUserWhereId(body, params.id).then(function(updated) {
        if (updated.length !== 1) {
          return end404();
        } else {
          return endJSON(omitPassword(updated[0]));
        }
      });
    });
  });
};
