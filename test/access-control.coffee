app = require '../app'

module.exports =

  'parseRight': (test) ->
    app (
      parseRight
    ) ->
      test.equal parseRight(''), null
      test.equal parseRight('# canGetUsers'), null
      test.equal parseRight(' canGetUsers'), null
      test.deepEqual parseRight('canGetUsers'),
        name: 'canGetUsers'
        args: []
      test.equal parseRight('canGetUsers('), null
      test.equal parseRight('canGetUsers(('), null
      test.equal parseRight('canGetUsers(())'), null
      test.deepEqual parseRight('canGetUsers()'),
        name: 'canGetUsers'
        args: []
      test.equal parseRight('canGetUsers)'), null
      test.deepEqual parseRight('canGetUsers(1)'),
        name: 'canGetUsers'
        args: [1]
      test.equal parseRight('canGetUsers(one)'), null
      test.equal parseRight('canGetUsers(\'one)'), null
      test.equal parseRight('canGetUsers(one\')'), null
      test.deepEqual parseRight('canGetUsers(\'one\')'),
        name: 'canGetUsers'
        args: ['one']
      test.deepEqual parseRight('canGetUsers( \'one\', 2, 3, \'four  \' )'),
        name: 'canGetUsers'
        args: ['one', 2, 3, 'four  ']
      test.equal parseRight('canGetUsers( \'one\', 2, 3, \'four  \',  )'), null

      test.done()
