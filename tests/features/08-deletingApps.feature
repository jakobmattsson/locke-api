Feature: Deleting an app

  Scenario: Deleting an app
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I create a new app "sally" with the username "test@user.com" and the last token
     When I delete the app "sally" with the username "test@user.com" and the password "pwwpas"
     Then I should get status "OK"
      And I get all the apps with the username "test@user.com" and the last token
      And I should get apps '{ }'

  Scenario: Attempting to delete an app with an invalid username
    Given A locke server running locally
     When I delete the app "sally" with the username "test@user.com" and the password "pwwpas"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'locke'"

  Scenario: Attempting to delete an app with an invalid password
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
     When I delete the app "sally" with the username "test@user.com" and the password "p1p1p1"
     Then I should get status "Incorrect password"

  Scenario: Attempting to delete an app with an invalid password
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
     When I delete the app "sally" with the username "test@user.com" and the password "pwwpas"
     Then I should get status "Could not find an app with the name 'sally'"

  Scenario: Deleting an app as another user
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I create a user for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I create a new app "sally" with the username "test2@user.com" and the last token
     When I delete the app "sally" with the username "test1@user.com" and the password "pwwpas"
     Then I should get status "Could not find an app with the name 'sally'"

  Scenario: Deleting an app as a non-admin
    Given A locke server running locally
      And I create a user for the app "locke" with the username "admin@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "admin@user.com" and password "pwwpas"
      And I create a new app "sally" with the username "admin@user.com" and the last token
      And I create a user for the app "sally" with the username "regular@user.com" and password "pwwpas"
     When I delete the app "sally" with the username "regular@user.com" and the password "pwwpas"
     Then I should get status "There is no user with the email 'regular@user.com' for the app 'locke'"

  Scenario: Deleting an app as a non-admin
    Given A locke server running locally
      And I create a user for the app "locke" with the username "admin@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "admin@user.com" and password "pwwpas"
      And I create a new app "sally" with the username "admin@user.com" and the last token
      And I create a user for the app "sally" with the username "regular@user.com" and password "pwwpas"
     When I delete the app "sally" with the username "admin@user.com" and the password "pwwpas"
     Then I should get status "OK"

  Scenario: Attempting to delete the locke app
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
     When I delete the app "locke" with the username "test@user.com" and the password "pwwpas"
     Then I should get status "Could not find an app with the name 'locke'"
