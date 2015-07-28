module.exports.requestPromise = function(Promise, request) {
  return Promise.promisify(request);
};

module.exports.faker = function() {
  return require('faker');
};

module.exports.siv = function() {
  return require('siv');
};

module.exports.waechter = function() {
  return require('waechter');
};
