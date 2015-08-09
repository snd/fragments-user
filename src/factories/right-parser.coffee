module.exports.functionSignatureParser = (
  pcom
) ->
  P = pcom

  F = {}

  F.number = P.firstChoice(P.integer, P.float)

  F.string = P.pick(1,
    P.string('\'')
    # match any char thats not a `'` or `\` or is a `\` followed by an arbitrary char
    # ?: is the non-capturing group
    P.regex(/^(?:[^'\\]|\\.)*/)
    P.string('\'')
  )

  F.name = P.regex(/^[a-zA-z0-9]+/)

  F.arg = P.pick(1,
    P.whitespace
    # P.firstChoice(F.string, P.integer, P.float)
    P.firstChoice(F.string, P.integer)
    P.whitespace
  )

  F.argsInParens = P.pick(2,
    P.string('(')
    P.whitespace
    P.separated(
      F.arg
      P.string(',')
    )
    P.whitespace
    P.string(')')
  )

  # TODO use P.pick with a mapping-object as first argument here
  F.signature = P.sequence(
    F.name
    P.maybe(F.argsInParens, [])
  )

  return F

module.exports.parseRight = (
  functionSignatureParser
) ->
  (string) ->
    parsed = functionSignatureParser.signature string
    unless parsed?
      return
    if parsed.rest isnt ''
      return

    right =
      name: parsed.value[0]
    if parsed.value[1]
      right.args = parsed.value[1]
    return right
