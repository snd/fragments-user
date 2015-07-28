module.exports.apiLogin = function(POST, urlApiLogin, newJwt, validateLogin, firstUserWhereLogin, _) {
  return POST(urlApiLogin(), function(body, endUnprocessableJSON, endUnprocessableText, endJSON) {
    var errors;
    errors = validateLogin(body);
    if (errors != null) {
      endUnprocessableJSON(errors);
      return;
    }
    return firstUserWhereLogin(body).then(function(user) {
      var token;
      if (user == null) {
        endUnprocessableText('invalid identifier (username or email) or password');
        return;
      }
      token = newJwt({
        id: user.id
      });
      return endJSON({
        token: token,
        user: _.omit(user, 'password')
      });
    });
  });
};
