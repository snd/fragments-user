fragments = require 'fragments'

module.exports =
  application: fragments.load './application'
  request: fragments.load './request'
