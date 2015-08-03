module.exports.testApiUserDelete = function(pgDropCreateMigrate, testHelperInsertUser, command_serve, selectUser, testHelperDelete, testHelperLogin, testHelperGrantUserRights, urlApiUsers, errorMessageForEndForbiddenTokenRequired, errorMessageForEndForbiddenInsufficientRights, shutdown) {
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
      return selectUser();
    }).then(function(users) {
      test.equal(users.length, 3);
      return command_serve();
    }).then(function() {
      console.log('unauthenticated');
      return testHelperDelete(null, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      console.log('authenticate');
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      console.log('unprivileged');
      return testHelperDelete(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      console.log('wrong privilege');
      return testHelperGrantUserRights('operator', ['canDeleteUsers(100)']);
    }).then(function() {
      return testHelperDelete(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      console.log('single user privilege');
      return testHelperGrantUserRights('operator', ["canDeleteUsers(" + this.other.id + ")"]);
    }).then(function() {
      return testHelperDelete(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body, '');
      return selectUser();
    }).then(function(users) {
      test.equal(users.length, 2);
      console.log('unprivileged');
      return testHelperDelete(this.token, urlApiUsers(this.another.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      console.log('privileged');
      return testHelperGrantUserRights('operator', ["canDeleteUsers()"]);
    }).then(function() {
      return testHelperDelete(this.token, urlApiUsers(this.another.id));
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body, '');
      return selectUser();
    }).then(function(users) {
      test.equal(users.length, 1);
      console.log('privileged but not found');
      return testHelperDelete(this.token, urlApiUsers(this.another.id));
    }).then(function(response) {
      return test.equal(response.statusCode, 404);
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
