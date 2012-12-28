introspect = require 'introspect'

exports.requireStringsAndCallback = (api) ->
  Object.keys(api).reduce (acc, key) ->
    params = introspect(api[key]).slice(0, -1)

    acc[key] = (args..., callback) ->
      throw new Error("Missing callback") if !callback? || typeof callback != 'function'

      diff = args.length - params.length
      return callback(new Error("Too many parameters")) if diff > 0
      return callback(new Error("Missing parameters: #{params.slice(diff).join(', ')}")) if diff < 0

      fails = params.filter (param, i) -> !args[i]? || args[i].toString().trim() == ''
      return callback(new Error("Missing parameters: #{fails.join(', ')}")) if fails.length > 0

      api[key].apply(api, args.concat([callback]))

    acc
  , {}
