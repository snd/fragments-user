module.exports.apiWaitlistPost = function(urlApiWaitlist, POST) {
  return POST(urlApiWaitlist(), function(waitlistValidator, endUnprocessableJSON, insertWaitlist, endCreatedJSON, body) {
    return waitlistValidator(body).then(function(errors) {
      if (errors != null) {
        return endUnprocessableJSON(errors);
      }
      return insertWaitlist(body).then(function(inserted) {
        return endCreatedJSON(inserted);
      });
    });
  });
};
