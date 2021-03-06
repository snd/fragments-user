module.exports.testApiUsersPost = function(pgDropCreateMigrate, command_serve, testHelperInsertUser, testHelperPost, testHelperLogin, testHelperGrantUserRights, urlApiUsers, errorMessageForEndForbiddenTokenRequired, errorMessageForEndForbiddenInsufficientRights, shutdown) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      return command_serve();
    }).then(function() {
      console.log('unauthenticated');
      return testHelperPost(null, urlApiUsers(), {
        email: 'other@example.com',
        name: 'other',
        password: 'topsecret',
        rights: ''
      });
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      console.log('authenticate');
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      console.log('unprivileged');
      return testHelperPost(this.token, urlApiUsers(), {
        email: 'other@example.com',
        name: 'other',
        password: 'topsecret',
        rights: ''
      });
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      console.log('continue with privileged');
      return testHelperGrantUserRights('operator', ['canPostUsers']);
    }).then(function() {
      console.log('unprocessable');
      return testHelperPost(this.token, urlApiUsers(), {
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
      return testHelperPost(this.token, urlApiUsers(), {
        email: 'operator@example.com',
        name: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        email: 'taken'
      });
      return testHelperPost(this.token, urlApiUsers(), {
        email: 'other@example.com',
        name: 'operator',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        name: 'taken'
      });
      return testHelperPost(this.token, urlApiUsers(), {
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
      console.log('success');
      return testHelperPost(this.token, urlApiUsers(), {
        email: 'other@example.com',
        name: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 201);
      test.equal(response.body.email, 'other@example.com');
      test.equal(response.body.name, 'other');
      test.equal(response.body.rights, '');
      test.equal(response.headers.location, urlApiUsers(response.body.id));
      console.log('can create user with rights');
      return testHelperPost(this.token, urlApiUsers(), {
        email: 'another@example.com',
        name: 'another',
        password: 'topsecret',
        rights: 'canPostUsers'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 201);
      test.equal(response.body.email, 'another@example.com');
      test.equal(response.body.name, 'another');
      test.equal(response.body.rights, 'canPostUsers');
      return test.equal(response.headers.location, urlApiUsers(response.body.id));
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
