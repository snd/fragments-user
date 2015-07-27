# just overwrite this if you need different behaviour
module.exports.apiSignup = (
  urlApiSignup
  POST
) ->
  POST urlApiSignup(), (
    validateSignup
    endUnprocessableJSON
    insertUser
    endCreatedJSON
    newJwt
    omitPassword
    body
  ) ->
    validateSignup(body).then (errors) ->
      if errors?
        return endUnprocessableJSON errors
      insertUser(body).then (inserted) ->
        endCreatedJSON
          # auto login after signup
          token: newJwt({id: inserted.id})
          user: omitPassword inserted
