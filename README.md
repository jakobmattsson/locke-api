locke-api [![Build Status](https://secure.travis-ci.org/jakobmattsson/locke-api.png)](http://travis-ci.org/jakobmattsson/locke-api)
=========

A generic API for a locke-implementation, dealing with access control and encryption.



ToDo
----
* Run other combinations of storages, for example mongodb and both mem and mongodb as secured
* Test SDL some more:
  * test that the password is not saved as plain text
  * test that a token salt is saved
  * test that the token salt cannot be overriden manually
