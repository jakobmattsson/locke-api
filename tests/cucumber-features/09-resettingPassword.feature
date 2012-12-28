Feature: Resetting password

  Scenario: Getting a reset email
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I request a reset for the username "test@user.com" in the app "sally"
     Then I should get an email at "test@user.com"
      And The last email should contain "sally"
      And The last email should contain "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "p1p1p1"
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "p1p1p1"
     Then I should get status "OK"

  Scenario: Attempting to reset an invalid app
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I request a reset for the username "test@user.com" in the app "something"
     Then I should get status "Could not find an app with the name 'something'"

  Scenario: Attempting to reset an invalid email
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I request a reset for the username "fail@user.com" in the app "sally"
     Then I should get status "There is no user with the email 'fail@user.com' for the app 'sally'"

  Scenario: Attempting to reset password using an invalid app
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "monkey" and username "test@user.com" with the last emailed token to "p1p1p1"
     Then I should get status "Could not find an app with the name 'monkey'"

  Scenario: Attempting to reset password using an invalid email
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "fail@user.com" with the last emailed token to "p1p1p1"
     Then I should get status "There is no user with the email 'fail@user.com' for the app 'sally'"

  Scenario: Attempting to reset password using an invalid token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the token "abc123" to "p1p1p1"
     Then I should get status "Incorrect token"

  Scenario: Attempting to reset password using a password that is too short
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "abc"
     Then I should get status "Password too short - use at least 6 characters"

  Scenario: Attempting to reset password using a password that is too common
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "abc123"
     Then I should get status "Password too common - use something more unique"

  Scenario: Attempting to use the same token twice
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I request a reset for the username "test@user.com" in the app "sally"
     Then I should get an email at "test@user.com"
      And The last email should contain "sally"
      And The last email should contain "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "p1p1p1"
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "p1p1p1"
     Then I should get status "OK"
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "p2p2p2"
     Then I should get status "Incorrect token"

  Scenario: Using the last of two generated tokens
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
     When I request a reset for the username "test@user.com" in the app "sally"
     Then I should get an email at "test@user.com"
      And The last email should contain "sally"
      And The last email should contain "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "p1p1p1"
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "p1p1p1"
     Then I should get status "OK"

  Scenario: Using the first of two generated tokens
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
     When I request a reset for the username "test@user.com" in the app "sally"
     Then I should get an email at "test@user.com"
      And The last email should contain "sally"
      And The last email should contain "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the second last emailed token to "p1p1p1"
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "p1p1p1"
     Then I should get status "OK"

  Scenario: Attempting to use an old unused reset token after a reset has been performed using another reset token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
     When I request a reset for the username "test@user.com" in the app "sally"
     Then I should get an email at "test@user.com"
      And The last email should contain "sally"
      And The last email should contain "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the second last emailed token to "p1p1p1"
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "p1p1p1"
     Then I should get status "OK"
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "p2p2p2"
     Then I should get status "Incorrect token"

  Scenario: Attempting to reset using a regular authentication token instead of a reset token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the last token to "p1p1p1"
     Then I should get status "Incorrect token"

  Scenario: Old sessions should still be alive after a password reset
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "p1p1p1"
      And I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and the last token
     Then I should get status "OK"

  Scenario: Attempting to reset password using another users reset token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a reset for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I create a user for the app "sally" with the username "test2@user.com" and password "pwwpas"
      And I request a reset for the username "test2@user.com" in the app "sally"
      And I should get an email at "test2@user.com"
      And The last email should contain a valid token
     When I resetPassword for app "sally" and username "test@user.com" with the last emailed token to "p1p1p1"
     Then I should get status "Incorrect token"
