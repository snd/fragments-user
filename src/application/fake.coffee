module.exports.generateFakeUser = (
  faker
) ->
  ->
    name: faker.internet.userName()
    email: faker.internet.email()
    password: faker.internet.password()
    rights: ''

module.exports.insertFakeUsers = (
  generateFakeUser
  userTable
) ->
  (count) ->
    fakeUsers = [0...count].map(generateFakeUser)
    userTable
      .unsafe()
      .insert(fakeUsers)
