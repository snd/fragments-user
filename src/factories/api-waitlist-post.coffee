module.exports.apiWaitlistPost = (
  urlApiWaitlist
  POST
) ->
  POST urlApiWaitlist(), (
    waitlistValidator
    endUnprocessableJSON
    insertWaitlist
    endCreatedJSON
    body
  ) ->
    waitlistValidator(body).then (errors) ->
      if errors?
        return endUnprocessableJSON errors
      insertWaitlist(body).then (inserted) ->
        endCreatedJSON inserted
