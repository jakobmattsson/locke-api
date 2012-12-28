should = require 'should'
mem = require 'locke-store-mem'
api = require('../coverage').require('index')

makeEmailMock = ->
  lastEmail = null

  send: (to, content, callback) ->
    lastEmail = { to: to, content: content }
    callback()

  getLastEmail: (callback) ->
    callback(null, lastEmail)

db = mem.factory()
emailClient = makeEmailMock()
locke = api.constructApi
  db: db
  emailClient: emailClient
  blacklistedPassword: ['hejsan', 'abc123']


fail = (err, msg) ->
  err.should.be.an.instanceof Error
  err.message.should.eql msg


describe "createUser", ->

  it "no args", (done) ->
    locke.createUser (err) ->
      fail err, 'Missing parameters: app, email, password'
      done()

  it "nothing", (done) ->
    f = -> locke.createUser()
    f.should.throw 'Missing callback'
    done()

  it "missing app", (done) ->
    locke.createUser undefined, 'jakob', 'foobar', (err) ->
      fail err, 'Missing parameters: app'
      done()

  it "missing app, empty string", (done) ->
    locke.createUser '', 'jakob', 'foobar', (err) ->
      fail err, 'Missing parameters: app'
      done()

  it "missing app, whitespace characters only", (done) ->
    locke.createUser '   ', 'jakob', 'foobar', (err) ->
      fail err, 'Missing parameters: app'
      done()

  it "missing user", (done) ->
    locke.createUser 'locke', undefined, 'foobar', (err) ->
      fail err, 'Missing parameters: email'
      done()

  it "missing password", (done) ->
    locke.createUser 'locke', 'jakob', undefined, (err) ->
      fail err, 'Missing parameters: password'
      done()

  it "missing password compeltly", (done) ->
    locke.createUser 'locke', 'jakob', (err) ->
      fail err, 'Missing parameters: password'
      done()

  it "missing password and username compeltly", (done) ->
    locke.createUser 'locke', (err) ->
      fail err, 'Missing parameters: email, password'
      done()

  it "too many parameters", (done) ->
    locke.createUser 'locke', 'jakob', 'foobar', 'foobar', (err) ->
      fail err, 'Too many parameters'
      done()

  it "too many parameters, without callback", (done) ->
    f = -> locke.createUser 'locke', 'jakob', 'foobar', 'foobar'
    f.should.throw('Missing callback')
    done()

  it "missing callback", (done) ->
    f = -> locke.createUser 'locke', 'jakob', 'foobar'
    f.should.throw('Missing callback')
    done()

  it "works", (done) ->
    locke.createUser 'locke', 'jakob', 'foobar', (err, data) ->
      should.not.exist err
      data.should.eql { password: 'foobar', validated: false }
      done()
