module.exports.testApiCurrentUserPatch = function(pgDropCreateMigrate, testHelperInsertUser, command_serve, testHelperPatch, testHelperLogin, urlApiCurrentUser, errorMessageForEndForbiddenTokenRequired, shutdown) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      testHelperInsertUser('other', 'other@example.com', 'topsecret');
      return command_serve();
    }).then(function() {
      console.log('unauthenticated');
      return testHelperPatch(null, urlApiCurrentUser(), {
        name: 'operatorchanged',
        email: 'emailchanged',
        password: 'topsecretchanged'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      console.log('authenticate');
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      console.log('unprocessable');
      return testHelperPatch(this.token, urlApiCurrentUser(), {
        email: 'dkjdlkf',
        name: '',
        password: '',
        rights: 'canAccessAllAndEverything # trying to escalate own rights should fail'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        name: 'must not be empty',
        password: 'must not be empty',
        email: 'must be an email address',
        rights: 'you are not allowed to set your own rights'
      });
      console.log('unprocessable because taken');
      return testHelperPatch(this.token, urlApiCurrentUser(), {
        email: 'other@example.com',
        name: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        name: 'taken',
        email: 'taken'
      });
      return testHelperPatch(this.token, urlApiCurrentUser(), {
        email: 'other@example.com',
        name: 'another',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        email: 'taken'
      });
      return testHelperPatch(this.token, urlApiCurrentUser(), {
        email: 'another@example.com',
        name: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        name: 'taken'
      });
      console.log('success but not change');
      return testHelperPatch(this.token, urlApiCurrentUser(), {
        email: 'operator@example.com',
        name: 'operator',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.email, 'operator@example.com');
      test.equal(response.body.name, 'operator');
      test.equal(response.body.rights, '');
      test.equal(response.body.password, null);
      console.log('success with change');
      return testHelperPatch(this.token, urlApiCurrentUser(), {
        email: 'operatorchanged@example.com',
        name: 'operatorchanged',
        password: 'topsecretchanged'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.email, 'operatorchanged@example.com');
      test.equal(response.body.name, 'operatorchanged');
      test.equal(response.body.rights, '');
      return test.equal(response.body.password, null);
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
