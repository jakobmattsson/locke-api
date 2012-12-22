crypto = require 'crypto'

noUser = (app, email) -> "There is no user with the email '#{email}' for the app '#{app}'"
noApp = (app) -> "Could not find an app with the name '#{app}'"

exports.construct = ({ db, emailClient, blacklistedPassword }) ->
  blacklistedPassword ?= []

  minPasswordLength = 6

  createToken = -> crypto.randomBytes(256 / 8).toString('hex')

  secondsInTheFuture = (seconds) -> Math.floor(new Date().getTime() / 1000) + seconds

  compareAndValidateToken = (app, email, type, token, callback) ->
    db.compareToken app, email, type, token, (err, tt) ->
      return callback(err) if err
      if tt.timeout * 1000 < new Date().getTime()
        return db.removeToken app, email, type, token, ->
          callback "Token timed out"
      callback()

  createUser: (app, email, password, callback) ->
    db.getUser app, email, (err, userInfo) ->
      return callback(err) if typeof err == 'string'
      return callback("The given email is already in use for this app") if userInfo?
      return callback("Password too short - use at least #{minPasswordLength} characters") if password.length < minPasswordLength
      return callback("Password too common - use something more unique") if blacklistedPassword.some((x) -> x == password)
      db.createUser app, email, { password: password, validated: false }, callback

  authPassword: (app, email, password, secondsToLive, callback) ->
    db.comparePassword app, email, password, (err, isMatch) ->
      return callback(err) if typeof err == 'string'
      return callback("Incorrect password") if !isMatch
      return callback("The parameter 'secondsToLive' must be an integer >0") if !/^[1-9][0-9]*$/.test(secondsToLive)

      token = createToken()
      tokenTimeout = secondsInTheFuture(parseInt(secondsToLive))
      db.getUser app, email, (err, userInfo) ->
        db.addToken app, email, 'auth', token, { timeout: tokenTimeout }, (err) ->
          return callback(err) if err
          callback null, { token: token, validated: userInfo.validated }

  authToken: (app, email, token, callback) ->
    db.getUser app, email, (err, userInfo) ->
      return callback(err) if typeof err == 'string'
      return callback(noUser(app, email)) if !userInfo?
      compareAndValidateToken app, email, 'auth', token, (err) ->
        return callback(err) if err
        callback null, { validated: userInfo.validated }

  createApp: (email, token, app, callback) ->
    db.getUser 'locke', email, (err, userInfo) ->
      return callback(noUser('locke', email)) if !userInfo?
      compareAndValidateToken 'locke', email, 'auth', token, (err) ->
        return callback(err) if err
        db.createApp email, app, callback

  getApps: (email, token, callback) ->
    db.getUser 'locke', email, (err, userInfo) ->
      return callback(noUser('locke', email)) if !userInfo?
      compareAndValidateToken 'locke', email, 'auth', token, (err) ->
        return callback(err) if typeof err == 'string'
        db.getApps email, (err, data) ->
          callback(null, { apps: data })

  closeSession: (app, email, token, callback) ->
    db.getUser app, email, (err, userInfo) ->
      return callback(err) if typeof err == 'string'
      return callback(noUser(app, email)) if !userInfo?
      compareAndValidateToken app, email, 'auth', token, (err) ->
        return callback(err) if err
        db.removeToken app, email, 'auth', token, callback

  closeSessions: (app, email, password, callback) ->
    db.comparePassword app, email, password, (err, isMatch) ->
      return callback(err) if typeof err == 'string'
      return callback("Incorrect password") if !isMatch
      db.removeAllTokens app, email, 'auth', callback

  deleteUser: (app, email, password, callback) ->
    db.comparePassword app, email, password, (err, isMatch) ->
      return callback(err) if typeof err == 'string'
      return callback("Incorrect password") if !isMatch
      db.removeUser app, email, callback

  updatePassword: (app, email, password, newPassword, callback) ->
    db.comparePassword app, email, password, (err, isMatch) ->
      return callback(err) if typeof err == 'string'
      return callback("Password too short - use at least #{minPasswordLength} characters") if newPassword.length < minPasswordLength
      return callback("Password too common - use something more unique") if blacklistedPassword.some((x) -> x == newPassword)
      return callback("Incorrect password") if !isMatch
      db.setUserData app, email, { password: newPassword }, callback

  deleteApp: (email, password, app, callback) ->
    db.comparePassword 'locke', email, password, (err, isMatch) ->
      return callback(err) if typeof err == 'string'
      return callback("Incorrect password") if !isMatch
      db.getApps email, (err, data) ->
        return callback(err) if typeof err == 'string'
        return callback(noApp(app)) if !data[app]?
        db.deleteApp app, callback

  sendPasswordReset: (app, email, callback) ->
    db.getUser app, email, (err, userInfo) ->
      return callback(err) if typeof err == 'string'
      return callback(noUser(app, email)) if !userInfo?
      token = createToken()
      tokenTimeout = secondsInTheFuture(86400)
      db.addToken app, email, 'reset', token, { timeout: tokenTimeout }, ->
        emailContent = app + " " + email + " " + token
        emailClient.send email, emailContent, callback

  resetPassword: (app, email, resetToken, newPassword, callback) ->
    db.getUser app, email, (err, userInfo) ->
      return callback(err) if typeof err == 'string'
      return callback(noUser(app, email)) if !userInfo?
      return callback("Password too short - use at least #{minPasswordLength} characters") if newPassword.length < minPasswordLength
      return callback("Password too common - use something more unique") if blacklistedPassword.some((x) -> x == newPassword)
      compareAndValidateToken app, email, 'reset', resetToken, (err) ->
        return callback(err) if err?
        db.removeAllTokens app, email, 'reset', ->
          db.setUserData app, email, { password: newPassword }, callback

  sendValidation: (app, email, callback) ->
    db.getUser app, email, (err, userInfo) ->
      return callback(err) if typeof err == 'string'
      return callback(noUser(app, email)) if !userInfo?
      return callback("The user has already been validated") if userInfo.validated
      token = createToken()
      tokenTimeout = secondsInTheFuture(86400)
      db.addToken app, email, 'validation', token, { timeout: tokenTimeout }, ->
        emailContent = app + " " + email + " " + token
        emailClient.send email, emailContent, callback

  validateUser: (app, email, validationToken, callback) ->
    db.getUser app, email, (err, userInfo) ->
      return callback(err) if typeof err == 'string'
      return callback(noUser(app, email)) if !userInfo?
      return callback("The user has already been validated") if userInfo.validated
      compareAndValidateToken app, email, 'validation', validationToken, (err) ->
        return callback(err) if err?
        db.removeAllTokens app, email, 'validation', ->
          db.setUserData app, email, { validated: true }, callback
