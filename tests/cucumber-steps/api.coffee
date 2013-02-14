_ = require 'underscore'
mem = require 'locke-store-mem'
nameify = require 'nameify'

steps = require './steps'
api = require('../coverage').require('index')

apispec =
  createUser: ["app", "email", "password"]
  authPassword: ["app", "email", "password", "secondsToLive"]
  authToken: ["app", "email", "token"]
  createApp: ["email", "token", "app"]
  getApps: ["email", "token"]
  closeSession: ["app", "email", "token"]
  closeSessions: ["app", "email", "password"]
  deleteUser: ["app", "email", "password"]
  updatePassword: ["app", "email", "password", "newPassword"]
  deleteApp: ["email", "password", "app"]
  sendPasswordReset: ["app", "email"]
  resetPassword: ["app", "email", "resetToken", "newPassword"]
  sendValidation: ["app", "email"]
  validateUser: ["app", "email", "validationToken"]

makeEmailMock = ->
  lastEmail = null

  send: (to, data, callback) ->
    content = data.app + " " + to + " " + data.token
    lastEmail = { to: to, content: content }
    callback()

  getLastEmail: (callback) ->
    callback(null, lastEmail)

lockeApi = (cli) -> (func, args, callback) ->
  cli func, args, (err, data) ->
    if err
      callback(null, { status: err })
    else
      callback(null, _.extend({}, data, { status: 'OK' }))


module.exports = ->
  db = mem.factory()
  emailClient = makeEmailMock()
  apiinstance = api.constructApi
    db: db
    emailClient: emailClient
    blacklistedPassword: ['hejsan', 'abc123']

  cli = nameify.byName(apiinstance, apispec)
  steps.factory.call(this, lockeApi(cli), emailClient.getLastEmail, db.clean)
