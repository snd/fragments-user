module.exports.requestPromise = (Promise, request) ->
  Promise.promisify(request)

module.exports.faker = ->
  require 'faker'

module.exports.siv = ->
  require 'siv'
