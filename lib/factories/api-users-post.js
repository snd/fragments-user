module.exports.apiUsersPost = function(urlApiUsers, POST) {
  return POST(urlApiUsers(), function(canPostUsers, endForbiddenTokenRequired, endForbiddenInsufficientRights, setHeaderLocation, endCreatedJSON, validateUserInsert, insertUser, endUnprocessableJSON, urlApiUsers, body, omitPassword, currentUser) {
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    if (!canPostUsers()) {
      return endForbiddenInsufficientRights();
    }
    return validateUserInsert(body).then(function(errors) {
      if (errors != null) {
        return endUnprocessableJSON(errors);
      }
      return insertUser(body).then(function(inserted) {
        setHeaderLocation(urlApiUsers(inserted.id));
        return endCreatedJSON(omitPassword(inserted));
      });
    });
  });
};
