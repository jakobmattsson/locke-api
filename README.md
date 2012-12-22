locke-api
=========

[![Build Status](https://secure.travis-ci.org/jakobmattsson/locke-api.png)](http://travis-ci.org/jakobmattsson/locke-api)

Command-line tool for turning poor man's JSON into actual (well-formatted) JSON.



ToDo
----
* Run other combinations of storages, for example mongodb and both mem and mongodb as secured
* Test SDL some more:
  * test that the password is not saved as plain text
  * test that a token salt is saved
  * test that the token salt cannot be overriden manually
