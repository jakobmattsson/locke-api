should = require 'should'
jscov = require 'jscov'
lockeApi = require jscov.cover('../..', 'lib', 'index')

mem = require 'locke-store-mem'
core = require 'locke-store-test'

noErr = (f) -> (err, rest...) ->
  should.not.exist err
  f(rest...)


makeEmailMock = ->
  lastEmail = null

  send: (to, data, callback) ->
    content = data.app + " " + to + " " + data.token
    lastEmail = { to: to, content: content }
    callback()

  getLastEmail: (callback) ->
    callback(null, lastEmail)

makeInterface = (transformComparisonResult) ->
  db = mem.factory()

  oldCompareToken = db.compareToken
  db.compareToken = (app, email, type, token, callback) ->
    oldCompareToken app, email, type, token, (err, stuff) ->
      callback(err, transformComparisonResult(stuff))

  lockeApi.constructApi
    db: db
    emailClient: makeEmailMock()
    blacklistedPassword: ['hejsan', 'abc123']



# These three tests verfies what happens if "db.compareToken" returns something unexpected.
# It should be possible for this to happen, but it has happened live (probably due to a corrupted database)
# so even if the tests appear useless; LEAVE THEM BE!
do ->
  it "should recover if db.compareToken returns null", (done) ->
    locke = makeInterface (x) -> null
    locke.createUser 'locke', 'test@mock.com', 'passpass', noErr ->
      locke.authPassword 'locke', 'test@mock.com', 'passpass', 10000, noErr (data) ->
        locke.authToken 'locke', 'test@mock.com', data.token, (err, info) ->
          err.message.should.eql 'Token timed out (could not find a valid timeout-property)'
          should.not.exist info
          done()

  it "should recover if db.compareToken returns an empty object", (done) ->
    locke = makeInterface (x) -> { }
    locke.createUser 'locke', 'test2@mock.com', 'passpass', noErr ->
      locke.authPassword 'locke', 'test2@mock.com', 'passpass', 10000, noErr (data) ->
        locke.authToken 'locke', 'test2@mock.com', data.token, (err, info) ->
          err.message.should.eql 'Token timed out (could not find a valid timeout-property)'
          should.not.exist info
          done()

  it "should recover if db.compareToken returns a timeout that is not a number", (done) ->
    locke = makeInterface (x) -> { timeout: 'foobar' }
    locke.createUser 'locke', 'test3@mock.com', 'passpass', noErr ->
      locke.authPassword 'locke', 'test3@mock.com', 'passpass', 10000, noErr (data) ->
        locke.authToken 'locke', 'test3@mock.com', data.token, (err, info) ->
          err.message.should.eql 'Token timed out (could not find a valid timeout-property)'
          should.not.exist info
          done()
