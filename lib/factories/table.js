module.exports.userTable = function(mesa, setCreatedAt) {
  return mesa.table('user').allow('created_at').queueBeforeEachInsert(setCreatedAt);
};
