#!/usr/bin/env node

var hinoki = require('hinoki');
var fragments = require('fragments');
var fragmentsPostgres = require('fragments-postgres');
var fragmentsUser = require('./src/fragments-user');

var source = hinoki.source([
  fragmentsUser,
  fragmentsPostgres,
  fragments.source,
  fragments.umgebung,
]);

source = hinoki.decorateSourceToAlsoLookupWithPrefix(source, 'fragments_');

module.exports = fragments(source);

if (require.main === module) {
  module.exports.runCommand();
}
