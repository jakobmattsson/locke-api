bcrypt = require 'bcrypt-nodejs'

propagate = (callback, f) ->
  (err, rest...) ->
    return callback(err) if err
    f(rest...)

extend = (target, rest...) ->
  rest.forEach (obj) ->
    for own key, value of obj
      target[key] = value
  target


noUser = (app, email) -> new Error("There is no user with the email '#{email}' for the app '#{app}'")
noNullPassword = -> new Error('Password cannot be null')
noEmptyPassword = -> new Error('Password must be a non-empty string')

hashPassword = (token, salt, callback) -> bcrypt.hash(token, salt, null, callback)
comparePassword = (password, hash, callback) -> bcrypt.compare(password, hash, callback)
genSaltSync = (rounds) -> bcrypt.genSaltSync(rounds)


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
      hashPassword token, userInfo.tokenSalt, propagate callback, (hash) ->
        db.compareToken app, user, kind, hash, callback

  comparePassword: (app, user, password, callback) ->
    db.getUser app, user, propagate callback, (userInfo) ->
      return callback(noUser(app, user)) if !userInfo?
      comparePassword password, userInfo.password, callback

  removeToken: (app, user, type, name, callback) ->
    db.getUser app, user, propagate callback, (userInfo) ->
      return callback(noUser(app, user)) if !userInfo?
      hashPassword name, userInfo.tokenSalt, propagate callback, (hash) ->
        db.removeToken app, user, type, hash, callback

  addToken: (app, user, type, name, tokenData, callback) ->
    db.getUser app, user, propagate callback, (userInfo) ->
      return callback(noUser(app, user)) if !userInfo?
      hashPassword name, userInfo.tokenSalt, propagate callback, (hash) ->
        db.addToken app, user, type, hash, tokenData, callback

  createUser: (app, user, userData, callback) ->
    return callback(noNullPassword()) if !userData?.password?
    return callback(noEmptyPassword()) if userData.password == '' || typeof userData.password != 'string'

    salt = genSaltSync(rounds)
    hashPassword userData.password, salt, propagate callback, (hash) ->
      data = extend({}, userData, { password: hash, tokenSalt: salt })
      db.createUser app, user, data, callback

  setUserData: (app, user, userData, callback) ->
    if userData? && Object.keys(userData).indexOf('password') != -1
      return callback(noNullPassword()) if !userData.password?
      return callback(noEmptyPassword()) if userData.password == '' || typeof userData.password != 'string'

    return callback(new Error("Cannot set the property tokenSalt")) if userData.tokenSalt?
    if userData.password?
      hashPassword userData.password, genSaltSync(rounds), propagate callback, (hash) ->
        db.setUserData app, user, { password: hash }, callback
    else
      db.setUserData app, user, userData, callback
