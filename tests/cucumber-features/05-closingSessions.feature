Feature: Signing up a user using jsonp and GET

  Scenario: Closing a single session
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I close the session for the app "sally" and the user "test@user.com" and the last token
      And I authenticate for the app "sally" with the username "test@user.com" and the last token
     Then I should get status "Incorrect token"

  Scenario: Closing multiple sessions
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I close the sessions for the app "sally" and the user "test@user.com" and the password "pwwpas"
      And I authenticate for the app "sally" with the username "test@user.com" and the last token
     Then I should get status "Incorrect token"
     When I authenticate for the app "sally" with the username "test@user.com" and the second last token
     Then I should get status "Incorrect token"

  Scenario: Closing a single session, with multiple present
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I close the session for the app "sally" and the user "test@user.com" and the last token
      And I authenticate for the app "sally" with the username "test@user.com" and the last token
     Then I should get status "Incorrect token"
     When I authenticate for the app "sally" with the username "test@user.com" and the second last token
     Then I should get status "OK"

  Scenario: Invalid app name for closeSession
    Given A locke server running locally
     When I close the session for the app "some-app" and the user "test@user.com" and the token "xyz"
     Then I should get status "Could not find an app with the name 'some-app'"

  Scenario: Invalid email for closeSession
    Given A locke server running locally
      And A fresh app "sally"
     When I close the session for the app "sally" and the user "test@user.com" and the token "xyz"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'sally'"

  Scenario: Invalid token for closeSession
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I close the session for the app "sally" and the user "test@user.com" and the token "xyz"
     Then I should get status "Incorrect token"

  Scenario: Invalid app name for closeSessions
    Given A locke server running locally
     When I close the sessions for the app "some-app" and the user "test@user.com" and the password "xyz"
     Then I should get status "Could not find an app with the name 'some-app'"

  Scenario: Invalid email for closeSessions
    Given A locke server running locally
      And A fresh app "sally"
     When I close the sessions for the app "sally" and the user "test@user.com" and the password "xyz"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'sally'"

  Scenario: Invalid token for closeSessions
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I close the sessions for the app "sally" and the user "test@user.com" and the password "xyz"
     Then I should get status "Incorrect password"

  Scenario: Closing a session with another user present
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test1@user.com" and password "pwwpas"
      And I create a user for the app "sally" with the username "test2@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test1@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test2@user.com" and password "pwwpas"
     When I close the session for the app "sally" and the user "test2@user.com" and the last token
      And I authenticate for the app "sally" with the username "test2@user.com" and the last token
     Then I should get status "Incorrect token"
     When I authenticate for the app "sally" with the username "test1@user.com" and the second last token
     Then I should get status "OK"
