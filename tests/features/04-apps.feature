Feature: Creating and listing apps

  Scenario: Creating and signing up for a new app
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
     When I create a new app "sally" with the username "test@user.com" and the last token
     Then I should get status "OK"
     When I create a user for the app "sally" with the username "sallyuser" and password "sallyp"
     Then I should get status "OK"
     When I get all the apps with the username "test@user.com" and the last token
     Then I should get status "OK"
     Then I should get apps '{ "sally": { "userCount": 1 } }'

  Scenario: Invalid locke-email for creating
    Given A locke server running locally
     When I create a new app "sally" with the username "test@user.com" and the token "123"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'locke'"

  Scenario: Invalid locke-token
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I create a user for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test2@user.com" and password "pwwpas"
     When I create a new app "sally" with the username "test1@user.com" and the last token
     Then I should get status "Incorrect token"

  Scenario: App name locke already taken
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
     When I create a new app "locke" with the username "test@user.com" and the last token
     Then I should get status "App name 'locke' is already in use"

  Scenario: User defined app name already taken
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I create a new app "sally" with the username "test@user.com" and the last token
     When I create a new app "sally" with the username "test@user.com" and the last token
     Then I should get status "App name 'sally' is already in use"

  Scenario: Invalid locke-email for getting apps
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I create a new app "google" with the username "test@user.com" and the last token
     When I get all the apps with the username "apa@user.com" and the last token
     Then I should get status "There is no user with the email 'apa@user.com' for the app 'locke'"

  Scenario: Invalid locke-token for getting apps
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I create a user for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I create a new app "google" with the username "test2@user.com" and the last token
     When I get all the apps with the username "test2@user.com" and the second last token
     Then I should get status "Incorrect token"

  Scenario: Invalid user for getting apps
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I create a user for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I create a new app "google" with the username "test2@user.com" and the last token
     When I get all the apps with the username "test1@user.com" and the second last token
     Then I should get status "OK"
      And I should get apps '{ }'

  Scenario: Invalid user for getting apps
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I create a new app "google" with the username "test1@user.com" and the last token
      And I create a user for the app "google" with the username "test2@user.com" and password "pwwpas"
      And I authenticate for the app "google" with the username "test2@user.com" and password "pwwpas"
     When I get all the apps with the username "test2@user.com" and the last token
     Then I should get status "There is no user with the email 'test2@user.com' for the app 'locke'"

  Scenario: Creating multiple apps
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test@user.com" and password "pwwpas"
      And I create a new app "google" with the username "test@user.com" and the last token
      And I create a new app "sally" with the username "test@user.com" and the last token
      And I create a new app "rester" with the username "test@user.com" and the last token
     When I get all the apps with the username "test@user.com" and the last token
     Then I should get apps '{ "sally": { "userCount": 0 }, "google": { "userCount": 0 }, "rester": { "userCount": 0 } }'

   Scenario: Listing apps when there are multiple locke-users with apps
     Given A locke server running locally
       And I create a user for the app "locke" with the username "test1@user.com" and password "pwwpas"
       And I create a user for the app "locke" with the username "test2@user.com" and password "pwwpas"
       And I authenticate for the app "locke" with the username "test1@user.com" and password "pwwpas"
       And I create a new app "google" with the username "test1@user.com" and the last token
       And I create a new app "sally" with the username "test1@user.com" and the last token
       And I authenticate for the app "locke" with the username "test2@user.com" and password "pwwpas"
       And I create a new app "rester" with the username "test2@user.com" and the last token
      When I get all the apps with the username "test1@user.com" and the second last token
      Then I should get apps '{ "sally": { "userCount": 0 }, "google": { "userCount": 0 } }'
      When I get all the apps with the username "test2@user.com" and the last token
      Then I should get apps '{ "rester": { "userCount": 0 } }'

  Scenario: Listing user count when there are multiple locke-users with apps
    Given A locke server running locally
      And I create a user for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I create a user for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I authenticate for the app "locke" with the username "test1@user.com" and password "pwwpas"
      And I create a new app "google" with the username "test1@user.com" and the last token
      And I create a new app "sally" with the username "test1@user.com" and the last token
      And I authenticate for the app "locke" with the username "test2@user.com" and password "pwwpas"
      And I create a new app "rester" with the username "test2@user.com" and the last token
      And I create a user for the app "google" with the username "g1@user.com" and password "pwwpas"
      And I create a user for the app "google" with the username "g2@user.com" and password "pwwpas"
      And I create a user for the app "rester" with the username "r1@user.com" and password "pwwpas"
     When I get all the apps with the username "test1@user.com" and the second last token
     Then I should get apps '{ "sally": { "userCount": 0 }, "google": { "userCount": 2 } }'
     When I get all the apps with the username "test2@user.com" and the last token
     Then I should get apps '{ "rester": { "userCount": 1 } }'

  Scenario: Creating a user, and successfully authenticating, for the sally-app
    Given A locke server running locally
      And A fresh app "sally"
     When I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I should get status "OK"
     When I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas" and TTL of "60"
     Then I should get status "OK"
      And I should get a valid token
     When I authenticate for the app "sally" with the username "test@user.com" and the last token
     Then I should get status "OK"
