module.exports.testApiLoginPost = function(pgDropCreateMigrate, command_serve, testHelperPost, testHelperGet, testHelperInsertUser, shutdown, urlApiLogin, urlApiCurrentUser, console) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return command_serve();
    }).then(function() {
      console.log('unprocessable no body');
      return testHelperPost(null, urlApiLogin(), null);
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        identifier: 'must not be null or undefined',
        password: 'must not be null or undefined'
      });
      console.log('unprocessable');
      return testHelperPost(null, urlApiLogin(), {
        identifier: 'operator',
        password: 'top'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        password: 'must be at least 8 characters long'
      });
      console.log('not found for email or username');
      return testHelperPost(null, urlApiLogin(), {
        identifier: 'operator',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.equal(response.body, 'invalid identifier (username or email) or password');
      console.log('insert a user so we can login');
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      console.log('wrong password');
      return testHelperPost(null, urlApiLogin(), {
        identifier: 'operator',
        password: 'opensesame'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.equal(response.body, 'invalid identifier (username or email) or password');
      console.log('login with email');
      return testHelperPost(null, urlApiLogin(), {
        identifier: 'operator@example.com',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.notEqual(response.body.token, null);
      test.equal(response.body.user.email, 'operator@example.com');
      test.equal(response.body.user.name, 'operator');
      test.equal(response.body.user.rights, '');
      test.equal(response.body.user.password, null);
      console.log('token is valid');
      return testHelperGet(response.body.token, urlApiCurrentUser());
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.email, 'operator@example.com');
      test.equal(response.body.name, 'operator');
      test.equal(response.body.rights, '');
      test.equal(response.body.password, null);
      console.log('login with name');
      return testHelperPost(null, urlApiLogin(), {
        identifier: 'operator',
        password: 'topsecret'
      });
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.notEqual(response.body.token, null);
      test.equal(response.body.user.email, 'operator@example.com');
      test.equal(response.body.user.name, 'operator');
      test.equal(response.body.user.rights, '');
      test.equal(response.body.user.password, null);
      console.log('token is valid');
      return testHelperGet(response.body.token, urlApiCurrentUser());
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
