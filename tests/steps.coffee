_ = require 'underscore'
should = require 'should'
sinon = require 'sinon'

exports.factory = (lockecore, getLastEmail, clearDB) ->
  before = this.Before.bind this
  after = this.After.bind this
  step = (pattern, callback) =>
    this.Given pattern, callback
    this.When pattern, callback
    this.Then pattern, callback

  clock = null
  allResults = []
  allEmails = []
  allEmailTokens = []

  lastResult = -> _(allResults).last()
  lastToken = -> _(allTokens()).last()
  lastEmailToken = -> _(allEmailTokens).last()
  lastEmail = -> _(allEmails).last()
  allTokens = -> _(allResults.map((res) -> res.token)).compact()

  locke = (f, a, c) -> 
    lockecore f, a, (err, data) ->
      allResults.push(data)
      c()

  before (callback) ->
    clock = sinon.useFakeTimers()
    allResults = []
    allEmails = []
    allEmailTokens = []
    callback()

  after (callback) ->
    clock.restore()
    callback()

  step /^A locke server running locally$/, (callback) ->
    clearDB(callback)

  step /^I create a user for the app "([^"]*)" with the username "([^"]*)" and password "([^"]*)"$/, (app, email, password, callback) ->
    locke 'createUser', { app: app, email: email, password: password }, callback

  step /^I authenticate for the app "([^"]*)" with the username "([^"]*)" and password "([^"]*)"$/, (app, email, password, callback) ->
    locke 'authPassword', { app: app, email: email, password: password, secondsToLive: 86400 }, callback

  step /^I authenticate for the app "([^"]*)" with the username "([^"]*)" and password "([^"]*)" and TTL of "([^"]*)"$/, (app, email, password, ttl, callback) ->
    locke 'authPassword', { app: app, email: email, password: password, secondsToLive: ttl }, callback

  step /^I authenticate for the app "([^"]*)" with the username "([^"]*)" and the token "([^"]*)"$/, (app, email, token, callback) ->
    locke 'authToken', { app: app, email: email, token: token }, callback

  step /^I authenticate for the app "([^"]*)" with the username "([^"]*)" and the last token$/, (app, email, callback) ->
    locke 'authToken', { app: app, email: email, token: lastToken() }, callback

  step /^I authenticate for the app "([^"]*)" with the username "([^"]*)" and the second last token$/, (app, email, callback) ->
    locke 'authToken', { app: app, email: email, token: _(allTokens()).last(2)[0] }, callback

  step /^I call a non\-existing function$/, (callback) ->
    locke 'doesNotExist', {}, callback

  step /^I create a new app "([^"]*)" with the username "([^"]*)" and the last token$/, (app, email, callback) ->
    locke 'createApp', { app: app, email: email, token: lastToken() }, callback

  step /^I create a new app "([^"]*)" with the username "([^"]*)" and the token "([^"]*)"$/, (app, email, token, callback) ->
    locke 'createApp', { app: app, email: email, token: token }, callback

  step /^I get all the apps with the username "([^"]*)" and the last token$/, (email, callback) ->
    locke 'getApps', { email: email, token: lastToken() }, callback

  step /^I get all the apps with the username "([^"]*)" and the second last token$/, (email, callback) ->
    locke 'getApps', { email: email, token: _(allTokens()).last(2)[0] }, callback

  step /^I close the session for the app "([^"]*)" and the user "([^"]*)" and the last token$/, (app, email, callback) ->
    locke 'closeSession', { app: app, email: email, token: lastToken() }, callback

  step /^I close the session for the app "([^"]*)" and the user "([^"]*)" and the token "([^"]*)"$/, (app, email, token, callback) ->
    locke 'closeSession', { app: app, email: email, token: token }, callback

  step /^I close the sessions for the app "([^"]*)" and the user "([^"]*)" and the password "([^"]*)"$/, (app, email, password, callback) ->
    locke 'closeSessions', { app: app, email: email, password: password }, callback

  step /^I delete the user "([^"]*)" from the app "([^"]*)" with the password "([^"]*)"$/, (email, app, password, callback) ->
    locke 'deleteUser', { app: app, email: email, password: password }, callback

  step /^I update the password for the user "([^"]*)" from the app "([^"]*)" with the password "([^"]*)" to "([^"]*)"$/, (email, app, password, newPassword, callback) ->
    locke 'updatePassword', { app: app, email: email, password: password, newPassword: newPassword }, callback

  step /^I delete the app "([^"]*)" with the username "([^"]*)" and the password "([^"]*)"$/, (app, email, password, callback) ->
    locke 'deleteApp', { app: app, email: email, password: password }, callback

  step /^I request a reset for the username "([^"]*)" in the app "([^"]*)"$/, (email, app, callback) ->
    locke 'sendPasswordReset', { app: app, email: email }, callback

  step /^I resetPassword for app "([^"]*)" and username "([^"]*)" with the last emailed token to "([^"]*)"$/, (app, email, newPassword, callback) ->
    locke 'resetPassword', { app: app, email: email, resetToken: lastEmailToken(), newPassword: newPassword }, callback

  step /^I resetPassword for app "([^"]*)" and username "([^"]*)" with the token "([^"]*)" to "([^"]*)"$/, (app, email, token, newPassword, callback) ->
    locke 'resetPassword', { app: app, email: email, resetToken: token, newPassword: newPassword }, callback

  step /^I resetPassword for app "([^"]*)" and username "([^"]*)" with the second last emailed token to "([^"]*)"$/, (app, email, newPassword, callback) ->
    locke 'resetPassword', { app: app, email: email, resetToken: _(allEmailTokens).last(2)[0], newPassword: newPassword  }, callback

  step /^I resetPassword for app "([^"]*)" and username "([^"]*)" with the last token to "([^"]*)"$/, (app, email, newPassword, callback) ->
    locke 'resetPassword', { app: app, email: email, resetToken: lastToken(), newPassword: newPassword }, callback

  step /^I request a validation email for the username "([^"]*)" in the app "([^"]*)"$/, (email, app, callback) ->
    locke 'sendValidation', { app: app, email: email }, callback

  step /^I validate for the app "([^"]*)" and username "([^"]*)" with the last emailed token$/, (app, email, callback) ->
    locke 'validateUser', { app: app, email: email, validationToken: lastEmailToken() }, callback

  step /^I validate for the app "([^"]*)" and username "([^"]*)" with the token "([^"]*)"$/, (app, email, token, callback) ->
    locke 'validateUser', { app: app, email: email, validationToken: token }, callback

  step /^I validate for the app "([^"]*)" and username "([^"]*)" with the last token$/, (app, email, callback) ->
    locke 'validateUser', { app: app, email: email, validationToken: lastToken() }, callback

  step /^I should get an email at "([^"]*)"$/, (email, callback) ->
    getLastEmail (err, {to, content}) ->
      to.should.eql(email)
      allEmails.push(content)
      callback()

  step /^The last email should contain "([^"]*)"$/, (content, callback) ->
    lastEmail().should.include content
    callback()

  step /^The last email should contain a valid token$/, (callback) ->
    lastEmail().should.match /[a-z0-9]{64}/
    allEmailTokens.push(lastEmail().match(/[a-z0-9]{64}/)[0])
    callback()

  step /^I should get a validation status of "([^"]*)"$/, (status, callback) ->
    lastResult().validated.toString().should.eql status
    callback()

  step /^I should get status "([^"]*)"$/, (status, callback) ->
    lastResult().status.should.eql status
    callback()

  step /^I should get a valid token$/, (callback) ->
    lastToken().should.match /^[a-z0-9]{64}$/
    callback()

  step /^All issued tokens should be different$/, (callback) ->
    _(allTokens()).uniq().length.should.eql allTokens().length
    callback()

  step /^I wait (\d+)\.(\d+) seconds$/, (seconds, decimal, callback) ->
    actualSeconds = parseFloat(seconds + "." + decimal)
    clock.tick(actualSeconds * 1000)
    callback()

  step /^I should get apps '([^']*)'$/, (apps, callback) ->
    lastResult().apps.should.eql JSON.parse(apps)
    callback()

  step /^A fresh app "([^"]*)"$/, (app, callback) ->
    email = 'owning-user-' + app
    password = 'allfornought'
    locke 'createUser', { app: 'locke', email: email, password: password }, ->
      locke 'authPassword', { app: 'locke', email: email, password: password, secondsToLive: 86400 }, ->
        locke 'createApp', { app: app, email: email, token: lastToken() }, callback
