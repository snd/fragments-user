module.exports.server = function(sequenz, MIDDLEWARE, commonMiddlewarePrelude, apiSignup, apiLogin, apiCurrentUserGet, apiCurrentUserPatch, apiCurrentUserDelete, apiUsersGet, apiUsersPost, apiUserGet, apiUserPatch, apiUserDelete) {
  return sequenz([
    commonMiddlewarePrelude, apiSignup, apiLogin, apiCurrentUserGet, apiCurrentUserPatch, apiCurrentUserDelete, apiUsersGet, apiUsersPost, apiUserGet, apiUserPatch, apiUserDelete, MIDDLEWARE(function(end404) {
      return end404();
    })
  ]);
};
