module.exports.testApiUserPatch = function(pgDropCreateMigrate, testHelperInsertUser, command_serve, selectUser, testHelperPatch, testHelperLogin, testHelperGrantUserRights, urlApiUsers, errorMessageForEndForbiddenTokenRequired, errorMessageForEndForbiddenInsufficientRights, shutdown) {
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
      console.log('unauthenticated');
      return testHelperPatch(null, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      console.log('authenticate');
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      console.log('unprivileged');
      return testHelperPatch(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      console.log('wrong privilege');
      return testHelperGrantUserRights('operator', ['canUpdateUsers(100)']);
    }).then(function() {
      return testHelperPatch(this.token, urlApiUsers(this.other.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      console.log('continue with single user privilege');
      return testHelperGrantUserRights('operator', ["canUpdateUsers(" + this.other.id + ")"]);
    }).then(function() {
      console.log('unprocessable');
      return testHelperPatch(this.token, urlApiUsers(this.other.id), {
        email: 'dkjdlkf',
        name: '',
        password: ''
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        name: 'must not be empty',
        password: 'must not be empty',
        email: 'must be an email address'
      });
      console.log('unprocessable because taken');
      return testHelperPatch(this.token, urlApiUsers(this.other.id), {
        email: 'operator@example.com',
        name: 'other',
        password: 'topsecret',
        rights: 'canAccessAllAndEverything'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        email: 'taken'
      });
      return testHelperPatch(this.token, urlApiUsers(this.other.id), {
        email: 'other@example.com',
        name: 'operator',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        name: 'taken'
      });
      return testHelperPatch(this.token, urlApiUsers(this.other.id), {
        email: 'operator@example.com',
        name: 'operator',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        email: 'taken',
        name: 'taken'
      });
      console.log('success with same data');
      return testHelperPatch(this.token, urlApiUsers(this.other.id), {
        email: 'other@example.com',
        name: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.id, this.other.id);
      test.equal(response.body.password, null);
      test.equal(response.body.name, 'other');
      test.equal(response.body.email, 'other@example.com');
      test.equal(response.body.rights, '');
      console.log('success with different data');
      return testHelperPatch(this.token, urlApiUsers(this.other.id), {
        email: 'otherchanged@example.com',
        name: 'otherchanged',
        password: 'topsecret',
        rights: 'canAccessEverything'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.id, this.other.id);
      test.equal(response.body.password, null);
      test.equal(response.body.name, 'otherchanged');
      test.equal(response.body.email, 'otherchanged@example.com');
      test.equal(response.body.rights, 'canAccessEverything');
      console.log('unprivileged');
      return testHelperPatch(this.token, urlApiUsers(this.another.id));
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      console.log('privileged');
      return testHelperGrantUserRights('operator', ["canUpdateUsers()"]);
    }).then(function() {
      return testHelperPatch(this.token, urlApiUsers(this.another.id), {
        email: 'another@example.com',
        name: 'another',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.id, this.another.id);
      test.equal(response.body.password, null);
      test.equal(response.body.name, 'another');
      test.equal(response.body.email, 'another@example.com');
      test.equal(response.body.rights, '');
      console.log('privileged but not found');
      return testHelperPatch(this.token, urlApiUsers(100), {
        email: 'yetanother@example.com',
        name: 'yetanother',
        password: 'topsecret'
      });
    }).then(function(response) {
      return test.equal(response.statusCode, 404);
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
