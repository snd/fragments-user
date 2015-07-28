module.exports.testApiUsersGet = function(pgDropCreateMigrate, command_serve, testHelperInsertUser, testHelperGrantUserRights, testHelperGet, testHelperLogin, urlApiUsers, errorMessageForEndForbiddenTokenRequired, errorMessageForEndForbiddenInsufficientRights, shutdown) {
  return function(test) {
    return pgDropCreateMigrate().bind({}).then(function() {
      return testHelperInsertUser('operator', 'operator@example.com', 'topsecret');
    }).then(function() {
      return testHelperInsertUser('a', 'a@yahoo.com', 'topsecret');
    }).then(function() {
      return testHelperInsertUser('b', 'b@gmail.com', 'topsecret');
    }).then(function() {
      return testHelperInsertUser('c', 'c@yahoo.com', 'topsecret');
    }).then(function() {
      return command_serve();
    }).then(function() {
      return testHelperGet(null, urlApiUsers());
    }).then(function(response) {
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenTokenRequired);
      return testHelperLogin(test, 'operator', 'topsecret');
    }).then(function(token) {
      this.token = token;
      return testHelperGet(this.token, urlApiUsers());
    }).then(function(response) {
      var querystring;
      test.equal(response.statusCode, 403);
      test.equal(response.body, errorMessageForEndForbiddenInsufficientRights);
      testHelperGrantUserRights('operator', ['canReadUsers']);
      querystring = ['limit=a', 'offset=a', 'order=cash', 'asc=bla', 'where[id][gt]=ab'].join('&');
      return testHelperGet(this.token, urlApiUsers() + '?' + querystring);
    }).then(function(response) {
      test.equal(response.statusCode, 422);
      test.deepEqual(response.body, {
        query: {
          limit: 'a',
          offset: 'a',
          order: 'cash',
          asc: 'bla',
          where: {
            id: {
              gt: 'ab'
            }
          }
        },
        errors: {
          limit: 'must be an integer',
          offset: 'must be an integer',
          order: 'ordering by this column is not allowed',
          asc: 'must be either the string `true` or the string `false`',
          where: {
            id: {
              gt: 'must be parsable as an integer'
            }
          }
        }
      });
      return testHelperGet(this.token, urlApiUsers());
    }).then(function(response) {
      var querystring;
      test.equal(response.statusCode, 200);
      test.equal(response.body.length, 4);
      querystring = ['where[email][contains]=yahoo', 'order=name', 'asc=false'].join('&');
      return testHelperGet(this.token, urlApiUsers() + '?' + querystring);
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.equal(response.body.length, 2);
      test.equal(response.body[0].name, 'c');
      return test.equal(response.body[1].name, 'a');
    })["finally"](function() {
      return shutdown();
    }).then(function() {
      return test.done();
    });
  };
};
