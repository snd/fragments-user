module.exports.testApiCurrentUserDelete = function(pgDropCreateMigrate, testHelperInsertUser, command_serve, testHelperLogin, testHelperDelete, testHelperGet, testHelperPost, urlApiCurrentUser, urlApiLogin, selectUser, errorMessageForEndForbiddenTokenRequired, shutdown) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      return command_serve();
    }).then(function() {
      console.log('unauthenticated');
      return testHelperDelete(null, urlApiCurrentUser());
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      console.log('authenticate');
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      console.log('delete');
      return testHelperDelete(this.token, urlApiCurrentUser());
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body, '');
      console.log('cant get current user after delete');
      return testHelperGet(this.token, urlApiCurrentUser());
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      console.log('cant login after delete');
      return testHelperPost(null, urlApiLogin(), {
        identifier: 'operator@example.com',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.equal(response.body, 'invalid identifier (username or email) or password');
      return selectUser();
    }).then(function(users) {
      return test.equal(users.length, 0);
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
