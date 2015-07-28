hinoki = require 'hinoki'

# TODO this might also be nice to have in the client
# there it would have a different implementation though
rightsSource = (key) ->
  prefix = 'fragments_can'
  if (0 is key.indexOf(prefix)) and (key.length > prefix.length)
    (currentUserHasRight) ->
      (args...) ->
        currentUserHasRight key.slice(prefix.length - 3), args...

module.exports = hinoki.source([
  __dirname + '/factories'
  rightsSource
])
