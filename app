#!/usr/bin/env node

var fragments = require('fragments');

module.exports = fragments({
  application: [
    (__dirname + '/src/application'),
    (__dirname + '/src/shared'),
  ],
  request: (__dirname + '/src/request'),
});

if (require.main === module) {
  module.exports.runCommand();
}
