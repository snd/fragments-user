#!/usr/bin/env node

var hinoki = require('hinoki');
var fragments = require('fragments');
var fragmentsPostgres = require('fragments-postgres');
var app = hinoki.source(__dirname + '/src/factories');
var umgebung = require('umgebung');

var source = hinoki.source([
  app,
  fragmentsPostgres,
  fragments.source,
  umgebung,
]);

source = hinoki.decorateSourceToAlsoLookupWithPrefix(source, 'fragments_');

module.exports = fragments(source);

if (require.main === module) {
  module.exports.runCommand();
}
