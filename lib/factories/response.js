module.exports.errorMessageForEndForbiddenTokenRequired = function(urlApiLogin) {
  return "Forbidden.\n\nPlease provide a valid access token in the HTTP Authorization header as shown here:\n`Authorization:Bearer your-token-goes-here`\n\n# How do i get a token ?\nIn the response when logging in with valid credentials.\nThe response body will be JSON and the token can be found in the property `token`.\n\n# How do i log in ?\nSend a POST request to " + (urlApiLogin()) + ".\ninclude the params (either as JSON or formencoded)\n`identifier` (either email or username) and `password`.\n\n# I have provided a token but i still get `Forbidden`:\nYour token is no longer valid (or it never was).\nLog in again to get a new valid token.";
};

module.exports.endForbiddenTokenRequired = function(endForbidden, errorMessageForEndForbiddenTokenRequired) {
  return function() {
    return endForbidden(errorMessageForEndForbiddenTokenRequired);
  };
};

module.exports.errorMessageForEndForbiddenInsufficientRights = function() {
  return "Forbidden.\n\nYou don't have the right to do that.";
};

module.exports.endForbiddenInsufficientRights = function(endForbidden, errorMessageForEndForbiddenInsufficientRights) {
  return function() {
    return endForbidden(errorMessageForEndForbiddenInsufficientRights);
  };
};
