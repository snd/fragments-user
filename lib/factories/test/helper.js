module.exports.testHelperInsertUser = function(insertUser) {
  return function(name, email, password) {
    return insertUser({
      name: name,
      email: email,
      password: password,
      rights: ''
    });
  };
};

module.exports.testHelperGrantUserRights = function(Promise, firstUserWhereName, grantUserRightWhereId) {
  return function(name, rights) {
    return firstUserWhereName(name).then(function(user) {
      if (user == null) {
        return Promise.reject(new Error("no user named `" + name + "`"));
      }
      return Promise.all(rights).each(function(right) {
        return grantUserRightWhereId(right, user.id);
      });
    });
  };
};

module.exports.testHelperRevokeUserRights = function(Promise, firstUserWhereName, revokeUserRightWhereId) {
  return function(name, rights) {
    return firstUserWhereName(name).then(function(user) {
      if (user == null) {
        return Promise.reject(new Error("no user named `" + name + "`"));
      }
      return Promise.all(rights).each(function(right) {
        return revokeUserRightWhereId(right, user.id);
      });
    });
  };
};

module.exports.testHelperRequest = function(got, envStringBaseUrl, Promise) {
  return function(token, method, path, body) {
    var options, url;
    url = envStringBaseUrl + path;
    options = {
      method: method
    };
    if (body != null) {
      options.body = body;
    }
    if (token != null) {
      options.headers = {
        authorization: "Bearer " + token
      };
    }
    return Promise.resolve(got(url, options))["catch"](got.HTTPError, function(err) {
      return err.response;
    }).then(function(res) {
      var contentType;
      contentType = res.headers['content-type'];
      if ((contentType != null) && 0 === contentType.indexOf('application/json')) {
        res.body = JSON.parse(res.body.toString());
      }
      return res;
    });
  };
};

module.exports.testHelperGet = function(testHelperRequest) {
  return function(token, path) {
    return testHelperRequest(token, 'GET', path);
  };
};

module.exports.testHelperPatch = function(testHelperRequest) {
  return function(token, path, body) {
    return testHelperRequest(token, 'PATCH', path, body);
  };
};

module.exports.testHelperPost = function(testHelperRequest) {
  return function(token, path, body) {
    return testHelperRequest(token, 'POST', path, body);
  };
};

module.exports.testHelperDelete = function(testHelperRequest) {
  return function(token, path) {
    return testHelperRequest(token, 'DELETE', path);
  };
};

module.exports.testHelperLogin = function(testHelperPost, urlApiLogin) {
  return function(test, identifier, password) {
    return testHelperPost(null, urlApiLogin(), {
      identifier: identifier,
      password: password
    }).then(function(response) {
      test.equal(response.statusCode, 200);
      test.notEqual(response.body.token, null);
      return response.body.token;
    });
  };
};
