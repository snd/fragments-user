module.exports.functionSignatureParser = function(pcom) {
  var F, P;
  P = pcom;
  F = {};
  F.number = P.firstChoice(P.integer, P.float);
  F.string = P.pick(1, P.string('\''), P.regex(/^(?:[^'\\]|\\.)*/), P.string('\''));
  F.name = P.regex(/^[a-zA-z0-9]+/);
  F.arg = P.pick(1, P.whitespace, P.firstChoice(F.string, P.integer), P.whitespace);
  F.argsInParens = P.pick(2, P.string('('), P.whitespace, P.separated(F.arg, P.string(',')), P.whitespace, P.string(')'));
  F.signature = P.sequence(F.name, P.maybe(F.argsInParens, []));
  return F;
};

module.exports.parseRight = function(functionSignatureParser) {
  return function(string) {
    var parsed, right;
    parsed = functionSignatureParser.signature(string);
    if (parsed == null) {
      return;
    }
    if (parsed.rest !== '') {
      return;
    }
    right = {
      name: parsed.value[0]
    };
    if (parsed.value[1]) {
      right.args = parsed.value[1];
    }
    return right;
  };
};
