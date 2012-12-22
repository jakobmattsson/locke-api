Feature: Update password

  Scenario: Update password
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I update the password for the user "test@user.com" from the app "sally" with the password "pwwpas" to "p2p2p2"
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "p2p2p2"
     Then I should get status "OK"

  Scenario: Update password for an app that does not exist
    Given A locke server running locally
      And A fresh app "sally"
     When I update the password for the user "test@user.com" from the app "test" with the password "pwwpas" to "p2p2p2"
     Then I should get status "Could not find an app with the name 'test'"

  Scenario: Update password for a user that does not exist
    Given A locke server running locally
      And A fresh app "sally"
     When I update the password for the user "test@user.com" from the app "sally" with the password "pwwpas" to "p2p2p2"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'sally'"

  Scenario: Update password with the wrong password
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I update the password for the user "test@user.com" from the app "sally" with the password "p1p1p1" to "p2p2p2"
     Then I should get status "Incorrect password"

  Scenario: Update password with a too short password
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I update the password for the user "test@user.com" from the app "sally" with the password "pwwpas" to "p2"
     Then I should get status "Password too short - use at least 6 characters"

  Scenario: Update password with a blacklisted password
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I update the password for the user "test@user.com" from the app "sally" with the password "pwwpas" to "abc123"
     Then I should get status "Password too common - use something more unique"
