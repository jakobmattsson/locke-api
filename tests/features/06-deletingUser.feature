Feature: Deleting a user

  Scenario: Delete user
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I delete the user "test@user.com" from the app "sally" with the password "pwwpas"
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'sally'"

  Scenario: Delete user from invalid app
    Given A locke server running locally
     When I delete the user "test@user.com" from the app "sally" with the password "pwwpas"
     Then I should get status "Could not find an app with the name 'sally'"

  Scenario: Delete user that does not exist
    Given A locke server running locally
     When I delete the user "test@user.com" from the app "locke" with the password "pwwpas"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'locke'"

  Scenario: Delete user
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I delete the user "test@user.com" from the app "sally" with the password "pwwpas!!"
     Then I should get status "Incorrect password"
