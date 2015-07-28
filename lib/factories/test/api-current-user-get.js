module.exports.testApiCurrentUserGet = function(pgDropCreateMigrate, testHelperInsertUser, testHelperLogin, testHelperGet, command_serve, urlApiCurrentUser, errorMessageForEndForbiddenTokenRequired, shutdown) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      return command_serve();
    }).then(function() {
      return testHelperGet(null, urlApiCurrentUser());
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      return testHelperGet(this.token, urlApiCurrentUser());
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.email, 'operator@example.com');
      test.equal(response.body.name, 'operator');
      test.equal(response.body.rights, '');
      return test.equal(response.body.password, null);
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
