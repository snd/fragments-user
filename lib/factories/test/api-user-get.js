module.exports.testApiUserGet = function(pgDropCreateMigrate, testHelperInsertUser, command_serve, selectUser, testHelperGet, testHelperLogin, testHelperGrantUserRights, urlApiUsers, errorMessageForEndForbiddenTokenRequired, errorMessageForEndForbiddenInsufficientRights, shutdown) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      return testHelperInsertUser('other', 'other@example.com', 'topsecret');
    }).then(function(user) {
      test.notEqual(user.id, null);
      this.other = user;
      return testHelperInsertUser('another', 'another@example.com', 'topsecret');
    }).then(function(user) {
      test.notEqual(user.id, null);
      this.another = user;
      return command_serve();
    }).then(function() {
      return testHelperGet(null, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      return testHelperGet(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      return testHelperGrantUserRights('operator', ['canReadUsers(100)']);
    }).then(function() {
      return testHelperGet(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      return testHelperGrantUserRights('operator', ["canReadUsers(" + this.other.id + ")"]);
    }).then(function() {
      return testHelperGet(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.id, this.other.id);
      test.equal(response.body.password, null);
      return testHelperGet(this.token, urlApiUsers(this.another.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      return testHelperGrantUserRights('operator', ["canReadUsers()"]);
    }).then(function() {
      return testHelperGet(this.token, urlApiUsers(this.another.id));
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.id, this.another.id);
      test.equal(response.body.password, null);
      return testHelperGet(this.token, urlApiUsers(100));
    }).then(function(response) {
      return test.equal(response.statusCode, 404);
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
