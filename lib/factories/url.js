module.exports.flexibleUrl = function() {
  return function(prefix) {
    return function(suffix) {
      if (suffix) {
        return prefix + '/' + suffix;
      } else {
        return prefix;
      }
    };
  };
};

module.exports.urlApi = function(flexibleUrl) {
  return flexibleUrl('/api');
};

module.exports.urlApiLogin = function(urlApi) {
  return function() {
    return urlApi('login');
  };
};

module.exports.urlApiSignup = function(urlApi) {
  return function() {
    return urlApi('signup');
  };
};

module.exports.urlApiCurrentUser = function(urlApi) {
  return function() {
    return urlApi('me');
  };
};

module.exports.urlApiUsers = function(flexibleUrl, urlApi) {
  return flexibleUrl(urlApi('users'));
};
