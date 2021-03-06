module.exports.testApiSignupPost = function(pgDropCreateMigrate, command_serve, testHelperInsertUser, testHelperPost, testHelperGet, urlApiSignup, urlApiCurrentUser, urlApiLogin, shutdown) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      return command_serve();
    }).then(function() {
      console.log('unprocessable');
      return testHelperPost(null, urlApiSignup(), null);
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        email: 'must not be null or undefined',
        name: 'must not be null or undefined',
        password: 'must not be null or undefined'
      });
      return testHelperPost(null, urlApiSignup(), {
        email: 'dkjdlkf',
        name: '',
        password: 'aaa',
        rights: 'canAccessAllAndEverything # trying to escalate own rights should fail'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        email: 'must be an email address',
        name: 'must not be empty',
        password: 'must be at least 8 characters long',
        rights: 'you are not allowed to set your own rights'
      });
      console.log('unprocessable email taken');
      return testHelperPost(null, urlApiSignup(), {
        email: 'operator@example.com',
        name: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        email: 'taken'
      });
      console.log('unprocessable name taken');
      return testHelperPost(null, urlApiSignup(), {
        email: 'other@example.com',
        name: 'operator',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        name: 'taken'
      });
      console.log('unprocessable email and name taken');
      return testHelperPost(null, urlApiSignup(), {
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
      return testHelperPost(null, urlApiSignup(), {
        email: 'other@example.com',
        name: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 201);
      test.notEqual(response.body.token, null);
      test.equal(response.body.user.email, 'other@example.com');
      test.equal(response.body.user.name, 'other');
      test.equal(response.body.user.rights, '');
      test.equal(response.body.user.password, null);
      this.token = response.body.token;
      console.log('a user that has signed up is logged in');
      return testHelperGet(this.token, urlApiCurrentUser());
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.email, 'other@example.com');
      test.equal(response.body.name, 'other');
      test.equal(response.body.rights, '');
      test.equal(response.body.password, null);
      console.log('a user that has signed up can login');
      return testHelperPost(null, urlApiLogin(), {
        identifier: 'other',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.token, this.token);
      test.equal(response.body.user.email, 'other@example.com');
      test.equal(response.body.user.name, 'other');
      test.equal(response.body.user.rights, '');
      return test.ok(response.body.user.password == null);
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
