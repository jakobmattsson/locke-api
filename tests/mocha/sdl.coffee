should = require 'should'
jscov = require 'jscov'
lockeApi = require jscov.cover('../..', 'lib', 'index')

mem = require 'locke-store-mem'
core = require 'locke-store-test'

createStore = ->
  store = mem.factory()
  secureStore = lockeApi.secure(store, 1)
  secureStore.coreStore = store
  secureStore

core.runTests createStore, (store, done) ->
  store.coreStore.clean(done)
