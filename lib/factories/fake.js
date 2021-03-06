module.exports.generateFakeUser = function(faker) {
  return function() {
    return {
      name: faker.internet.userName(),
      email: faker.internet.email(),
      password: faker.internet.password(),
      rights: ''
    };
  };
};

module.exports.insertFakeUsers = function(generateFakeUser, userTable) {
  return function(count) {
    var fakeUsers, i, results;
    fakeUsers = (function() {
      results = [];
      for (var i = 0; 0 <= count ? i < count : i > count; 0 <= count ? i++ : i--){ results.push(i); }
      return results;
    }).apply(this).map(generateFakeUser);
    return userTable.unsafe().insert(fakeUsers);
  };
};
