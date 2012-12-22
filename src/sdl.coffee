bcrypt = require 'bcrypt'

propagate = (callback, f) ->
  (err, rest...) ->
    return callback(err) if err
    f(rest...)

extend = (target, rest...) ->
  rest.forEach (obj) ->
    for own key, value of obj
      target[key] = value
  target


noUser = (app, email) -> "There is no user with the email '#{email}' for the app '#{app}'"
noNullPassword = -> 'Password cannot be null'
noEmptyPassword = -> 'Password must be a non-empty string'


exports.secure = (db, rounds) ->
  getApps: db.getApps
  createApp: db.createApp
  deleteApp: db.deleteApp
  removeAllTokens: db.removeAllTokens
  getUser: db.getUser
  removeUser: db.removeUser

  compareToken: (app, user, kind, token, callback) ->
    db.getUser app, user, propagate callback, (userInfo) ->
      return callback(noUser(app, user)) if !userInfo?
      bcrypt.hash token, userInfo.tokenSalt, propagate callback, (hash) ->
        db.compareToken app, user, kind, hash, callback

  comparePassword: (app, user, password, callback) ->
    db.getUser app, user, propagate callback, (userInfo) ->
      return callback(noUser(app, user)) if !userInfo?
      bcrypt.compare password, userInfo.password, callback

  removeToken: (app, user, type, name, callback) ->
    db.getUser app, user, propagate callback, (userInfo) ->
      return callback(noUser(app, user)) if !userInfo?
      bcrypt.hash name, userInfo.tokenSalt, propagate callback, (hash) ->
        db.removeToken app, user, type, hash, callback

  addToken: (app, user, type, name, tokenData, callback) ->
    db.getUser app, user, propagate callback, (userInfo) ->
      return callback(noUser(app, user)) if !userInfo?
      bcrypt.hash name, userInfo.tokenSalt, propagate callback, (hash) ->
        db.addToken app, user, type, hash, tokenData, callback

  createUser: (app, user, userData, callback) ->
    return callback(noNullPassword()) if !userData?.password?
    return callback(noEmptyPassword()) if userData.password == '' || typeof userData.password != 'string'

    bcrypt.hash userData.password, rounds, propagate callback, (hash) ->
      data = extend({}, userData, { password: hash, tokenSalt: bcrypt.genSaltSync(rounds) })
      db.createUser app, user, data, callback

  setUserData: (app, user, userData, callback) ->
    if userData? && Object.keys(userData).indexOf('password') != -1
      return callback(noNullPassword()) if !userData.password?
      return callback(noEmptyPassword()) if userData.password == '' || typeof userData.password != 'string'

    return callback("Cannot set the property tokenSalt") if userData.tokenSalt?
    if userData.password?
      bcrypt.hash userData.password, rounds, propagate callback, (hash) ->
        db.setUserData app, user, { password: hash }, callback
    else
      db.setUserData app, user, userData, callback
