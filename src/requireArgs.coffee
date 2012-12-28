introspect = require 'introspect'

renameArguments = (__crazyLongParameterNameSoItDoesNotClashWithTheEvaledArguments, args) ->
  targetFunc    = "__crazyLongParameterNameSoItDoesNotClashWithTheEvaledArguments"

  throw new Error("args must be an array") if !Array.isArray(args)
  throw new Error("args must be an array of strings") if args.some (arg) -> typeof arg != 'string'
  throw new Error("The name '#{sourceFunction}' cant be used as an argument name") if args.some (arg) -> arg == targetFunc
  throw new Error("The name 'arguments' cant be used as an argument name") if args.some (arg) -> arg == 'arguments'
  throw new Error("Arguments can't contain the the symbol ')' or ',") if args.some (arg) -> arg.indexOf(')') != -1 || arg.indexOf(',') != -1

  eval("var anon = function(" + args.join(', ') + ") { return " + targetFunc + ".apply(this, arguments); }; anon;")

exports.requireStringsAndCallback = (api) ->
  Object.keys(api).reduce (acc, key) ->
    allParams = introspect(api[key])
    params = allParams.slice(0, -1)

    f = (args..., callback) ->
      throw new Error("Missing callback") if !callback? || typeof callback != 'function'

      diff = args.length - params.length
      return callback(new Error("Too many parameters")) if diff > 0
      return callback(new Error("Missing parameters: #{params.slice(diff).join(', ')}")) if diff < 0

      fails = params.filter (param, i) -> !args[i]? || args[i].toString().trim() == ''
      return callback(new Error("Missing parameters: #{fails.join(', ')}")) if fails.length > 0

      api[key].apply(api, args.concat([callback]))

    acc[key] = renameArguments(f, allParams)
    acc
  , {}
