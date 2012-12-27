crypto = require 'crypto'

noUser = (app, email) -> new Error("There is no user with the email '#{email}' for the app '#{app}'")
noApp = (app) -> new Error("Could not find an app with the name '#{app}'")

wrappErr = (callback) ->
  (err, rest...) ->
    return callback(new Error(err)) if typeof err == 'string'
    return callback(err) if err?
    callback.apply(this, arguments)

propagate = (callback, f) ->
  (err, rest...) ->
    return callback(new Error(err)) if typeof err == 'string'
    return callback(err) if err?
    f(rest...)

exports.construct = ({ db, emailClient, blacklistedPassword }) ->
  blacklistedPassword ?= []

  minPasswordLength = 6

  createToken = -> crypto.randomBytes(256 / 8).toString('hex')

  secondsInTheFuture = (seconds) -> Math.floor(new Date().getTime() / 1000) + seconds

  compareAndValidateToken = (app, email, type, token, callback) ->
    db.compareToken app, email, type, token, propagate callback, (tt) ->
      if tt.timeout * 1000 < new Date().getTime()
        return db.removeToken app, email, type, token, ->
          callback(new Error("Token timed out"))
      callback()

  createUser: (app, email, password, callback) ->
    db.getUser app, email, propagate callback, (userInfo) ->
      return callback(new Error("The given email is already in use for this app")) if userInfo?
      return callback(new Error("Password too short - use at least #{minPasswordLength} characters")) if password.length < minPasswordLength
      return callback(new Error("Password too common - use something more unique")) if blacklistedPassword.some((x) -> x == password)
      db.createUser app, email, { password: password, validated: false }, wrappErr callback

  authPassword: (app, email, password, secondsToLive, callback) ->
    db.comparePassword app, email, password, propagate callback, (isMatch) ->
      return callback(new Error("Incorrect password")) if !isMatch
      return callback(new Error("The parameter 'secondsToLive' must be an integer >0")) if !/^[1-9][0-9]*$/.test(secondsToLive)

      token = createToken()
      tokenTimeout = secondsInTheFuture(parseInt(secondsToLive))
      db.getUser app, email, (err, userInfo) ->
        db.addToken app, email, 'auth', token, { timeout: tokenTimeout }, propagate callback, ->
          callback null, { token: token, validated: userInfo.validated }

  authToken: (app, email, token, callback) ->
    db.getUser app, email, propagate callback, (userInfo) ->
      return callback(noUser(app, email)) if !userInfo?
      compareAndValidateToken app, email, 'auth', token, propagate callback, ->
        callback null, { validated: userInfo.validated }

  createApp: (email, token, app, callback) ->
    db.getUser 'locke', email, (err, userInfo) ->
      return callback(noUser('locke', email)) if !userInfo?
      compareAndValidateToken 'locke', email, 'auth', token, propagate callback, ->
        db.createApp email, app, wrappErr callback

  getApps: (email, token, callback) ->
    db.getUser 'locke', email, (err, userInfo) ->
      return callback(noUser('locke', email)) if !userInfo?
      compareAndValidateToken 'locke', email, 'auth', token, propagate callback, ->
        db.getApps email, (err, data) ->
          callback(null, { apps: data })

  closeSession: (app, email, token, callback) ->
    db.getUser app, email, propagate callback, (userInfo) ->
      return callback(noUser(app, email)) if !userInfo?
      compareAndValidateToken app, email, 'auth', token, propagate callback, ->
        db.removeToken app, email, 'auth', token, wrappErr callback

  closeSessions: (app, email, password, callback) ->
    db.comparePassword app, email, password, propagate callback, (isMatch) ->
      return callback(new Error("Incorrect password")) if !isMatch
      db.removeAllTokens app, email, 'auth', wrappErr callback

  deleteUser: (app, email, password, callback) ->
    db.comparePassword app, email, password, propagate callback, (isMatch) ->
      return callback(new Error("Incorrect password")) if !isMatch
      db.removeUser app, email, wrappErr callback

  updatePassword: (app, email, password, newPassword, callback) ->
    db.comparePassword app, email, password, propagate callback, (isMatch) ->
      return callback(new Error("Password too short - use at least #{minPasswordLength} characters")) if newPassword.length < minPasswordLength
      return callback(new Error("Password too common - use something more unique")) if blacklistedPassword.some((x) -> x == newPassword)
      return callback(new Error("Incorrect password")) if !isMatch
      db.setUserData app, email, { password: newPassword }, wrappErr callback

  deleteApp: (email, password, app, callback) ->
    db.comparePassword 'locke', email, password, propagate callback, (isMatch) ->
      return callback(new Error("Incorrect password")) if !isMatch
      db.getApps email, propagate callback, (data) ->
        return callback(noApp(app)) if !data[app]?
        db.deleteApp app, wrappErr callback

  sendPasswordReset: (app, email, callback) ->
    db.getUser app, email, propagate callback, (userInfo) ->
      return callback(noUser(app, email)) if !userInfo?
      token = createToken()
      tokenTimeout = secondsInTheFuture(86400)
      db.addToken app, email, 'reset', token, { timeout: tokenTimeout }, ->
        emailContent = app + " " + email + " " + token
        emailClient.send email, emailContent, wrappErr callback

  resetPassword: (app, email, resetToken, newPassword, callback) ->
    db.getUser app, email, propagate callback, (userInfo) ->
      return callback(noUser(app, email)) if !userInfo?
      return callback(new Error("Password too short - use at least #{minPasswordLength} characters")) if newPassword.length < minPasswordLength
      return callback(new Error("Password too common - use something more unique")) if blacklistedPassword.some((x) -> x == newPassword)
      compareAndValidateToken app, email, 'reset', resetToken, propagate callback, ->
        db.removeAllTokens app, email, 'reset', ->
          db.setUserData app, email, { password: newPassword }, wrappErr callback

  sendValidation: (app, email, callback) ->
    db.getUser app, email, propagate callback, (userInfo) ->
      return callback(noUser(app, email)) if !userInfo?
      return callback(new Error("The user has already been validated")) if userInfo.validated
      token = createToken()
      tokenTimeout = secondsInTheFuture(86400)
      db.addToken app, email, 'validation', token, { timeout: tokenTimeout }, ->
        emailContent = app + " " + email + " " + token
        emailClient.send email, emailContent, wrappErr callback

  validateUser: (app, email, validationToken, callback) ->
    db.getUser app, email, propagate callback, (userInfo) ->
      return callback(noUser(app, email)) if !userInfo?
      return callback(new Error("The user has already been validated")) if userInfo.validated
      compareAndValidateToken app, email, 'validation', validationToken, propagate callback, ->
        db.removeAllTokens app, email, 'validation', ->
          db.setUserData app, email, { validated: true }, wrappErr callback
