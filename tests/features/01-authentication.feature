Feature: Authenticate a user

  Scenario: Creating a user, and successfully authenticating, for the locke-app
    Given A locke server running locally
     When I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I should get status "OK"
     When I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas" and TTL of "60"
     Then I should get status "OK"
      And I should get a valid token
     When I authenticate for the app "locke" with the username "test@user.com" and the last token
     Then I should get status "OK"

  Scenario: Attempting to create a user for a non-existing app
    Given A locke server running locally
     When I create a user for the app "does-not-exist" with the username "test@user.com" and password "some_password"
     Then I should get status "Could not find an app with the name 'does-not-exist'"

  Scenario: Attempting to create a user that already exists
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I create a user for the app "locke" with the username "test@user.com" and password "another_password"
     Then I should get status "The given email is already in use for this app"

  Scenario: Attempting to create a user with a password that is too short
    Given A locke server running locally
     When I create a user for the app "locke" with the username "test@user.com" and password "pwwpa"
     Then I should get status "Password too short - use at least 6 characters"

  Scenario: Attempting to create a user with a password that is too common
    Given A locke server running locally
     When I create a user for the app "locke" with the username "test@user.com" and password "abc123"
     Then I should get status "Password too common - use something more unique"

  Scenario: Authenticating password for a nonexisting app
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "non-existing48585238" with the username "test@user.com" and password "some_password"
     Then I should get status "Could not find an app with the name 'non-existing48585238'"

  Scenario: Authenticating password for a nonexisting user
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "non-existing-user65465642" and password "some_password"
     Then I should get status "There is no user with the email 'non-existing-user65465642' for the app 'locke'"

  Scenario: Authenticating password with the wrong password
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and password "another-password"
     Then I should get status "Incorrect password"

  Scenario: Authenticating password with a non-number for TTL
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and password "some_password" and TTL of "twenty"
     Then I should get status "The parameter 'secondsToLive' must be an integer >0"

  Scenario: Authenticating password with a negative number for TTL
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and password "some_password" and TTL of "-5"
     Then I should get status "The parameter 'secondsToLive' must be an integer >0"

  Scenario: Authenticating password with a TTL of zero
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and password "some_password" and TTL of "0"
     Then I should get status "The parameter 'secondsToLive' must be an integer >0"

  Scenario: Authenticating password with a floating point number for TTL
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and password "some_password" and TTL of "1.2"
     Then I should get status "The parameter 'secondsToLive' must be an integer >0"

  Scenario: Authentication token with a non-existing app
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
      And I authenticate for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "non-existing48585238" with the username "test@user.com" and the last token
     Then I should get status "Could not find an app with the name 'non-existing48585238'"

  Scenario: Authentication token with a non-existing user
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
      And I authenticate for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "non-existing534752735" and the last token
     Then I should get status "There is no user with the email 'non-existing534752735' for the app 'locke'"

  Scenario: Authentication token with an incorrect token
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
      And I authenticate for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and the token "apa"
     Then I should get status "Incorrect token"

  Scenario: Authenticating password with a string starting with a number as TTL
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and password "some_password" and TTL of "23foobar"
     Then I should get status "The parameter 'secondsToLive' must be an integer >0"

  Scenario: Authentication one user with the password of another user
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "some_password"
      And I create a user for the app "locke" with the username "test2@user.com" and password "other_password"
     When I authenticate for the app "locke" with the username "test2@user.com" and password "some_password"
     Then I should get status "Incorrect password"

  Scenario: Authenticating an unauthenticated user with the token of another user
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "some_password"
      And I create a user for the app "locke" with the username "test2@user.com" and password "other_password"
      And I authenticate for the app "locke" with the username "test1@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test2@user.com" and the last token
     Then I should get status "Incorrect token"

  Scenario: Authenticating an authenticated user with the token of another user
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "some_password"
      And I create a user for the app "locke" with the username "test2@user.com" and password "other_password"
      And I authenticate for the app "locke" with the username "test1@user.com" and password "some_password"
      And I authenticate for the app "locke" with the username "test2@user.com" and password "other_password"
     When I authenticate for the app "locke" with the username "test1@user.com" and the last token
     Then I should get status "Incorrect token"

  Scenario: One user should get new tokens at every login
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "some_password"
      And I authenticate for the app "locke" with the username "test@user.com" and password "some_password"
     When I authenticate for the app "locke" with the username "test@user.com" and password "some_password"
     Then All issued tokens should be different

  Scenario: Setting a low TTL, but requesting within time
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas" and TTL of "2"
      And I wait 0.2 seconds
     When I authenticate for the app "locke" with the username "test@user.com" and the last token
     Then I should get status "OK"

  Scenario: Timing out from the TTL
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas" and TTL of "1"
      And I wait 1.2 seconds
     When I authenticate for the app "locke" with the username "test@user.com" and the last token
     Then I should get status "Token timed out"

  Scenario: Timing out from the TTL and then attempting to use the same token once again
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas" and TTL of "1"
      And I wait 1.2 seconds
      And I authenticate for the app "locke" with the username "test@user.com" and the last token
     When I authenticate for the app "locke" with the username "test@user.com" and the last token
     Then I should get status "Incorrect token"

  Scenario: Using the second last token
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
     When I authenticate for the app "locke" with the username "test@user.com" and the second last token
     Then I should get status "OK"
