path = require 'path'

exports.require = (file) ->
  require(path.join(__dirname, '..', process.env.SRC_DIR || 'lib', file))
