module.exports.apiSignup = function(urlApiSignup, POST) {
  return POST(urlApiSignup(), function(validateSignup, endUnprocessableJSON, insertUser, endCreatedJSON, newJwt, omitPassword, body) {
    return validateSignup(body).then(function(errors) {
      if (errors != null) {
        return endUnprocessableJSON(errors);
      }
      return insertUser(body).then(function(inserted) {
        return endCreatedJSON({
          token: newJwt({
            id: inserted.id
          }),
          user: omitPassword(inserted)
        });
      });
    });
  });
};
