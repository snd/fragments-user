module.exports.apiUsersGet = function(urlApiUsers, GET) {
  return GET(urlApiUsers(), function(userTable, query, siv, endJSON, endForbidden, endForbiddenTokenRequired, endForbiddenInsufficientRights, endUnprocessableJSON, canGetUsers, omitPassword, currentUser, _) {
    var sql;
    if (currentUser == null) {
      return endForbiddenTokenRequired();
    }
    if (!canGetUsers()) {
      return endForbiddenInsufficientRights();
    }
    sql = userTable;
    sql = siv.limit(sql, query);
    sql = siv.offset(sql, query);
    sql = siv.order(sql, query, {
      order: 'created_at',
      asc: false,
      allow: ['created_at', 'id', 'name', 'email']
    });
    sql = siv.integer(sql, query, 'id');
    sql = siv.string(sql, query, 'email');
    sql = siv.string(sql, query, 'name');
    sql = siv.date(sql, query, 'created_at');
    if (siv.isError(sql)) {
      return endUnprocessableJSON({
        query: query,
        errors: sql.json
      });
    } else {
      return sql.find().then(function(users) {
        return endJSON(omitPassword(users));
      });
    }
  });
};
