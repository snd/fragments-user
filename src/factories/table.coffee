module.exports.userTable = (
  mesa
  setCreatedAt
) ->
  mesa
    .table('user')
    # TODO this gets overwritten, not added to. change that !
    .allow('created_at')
    .queueBeforeEachInsert(setCreatedAt)
