Feature: Validation of a user email

  Scenario: Creating a user and successfully validating
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "validation@user.com" and password "pwwpas"
     When I authenticate for the app "sally" with the username "validation@user.com" and password "pwwpas"
     Then I should get a validation status of "false"
     When I authenticate for the app "sally" with the username "validation@user.com" and the last token
     Then I should get a validation status of "false"
     When I request a validation email for the username "validation@user.com" in the app "sally"
     Then I should get an email at "validation@user.com"
      And The last email should contain "sally"
      And The last email should contain "validation@user.com"
      And The last email should contain a valid token
     When I validate for the app "sally" and username "validation@user.com" with the last emailed token
     Then I should get status "OK"
     When I authenticate for the app "sally" with the username "validation@user.com" and password "pwwpas"
     Then I should get a validation status of "true"
      And I should get status "OK"
     When I authenticate for the app "sally" with the username "validation@user.com" and the last token
     Then I should get a validation status of "true"
      And I should get status "OK"

  Scenario: Attempting to request a validation email for an invalid app
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I request a validation email for the username "test@user.com" in the app "something"
     Then I should get status "Could not find an app with the name 'something'"

  Scenario: Attempting to request a validation email for an invalid email
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
     When I request a validation email for the username "fail@user.com" in the app "sally"
     Then I should get status "There is no user with the email 'fail@user.com' for the app 'sally'"

  Scenario: Attempting to request a validation email for a user that has already been validated
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I validate for the app "sally" and username "test@user.com" with the last emailed token
     When I request a validation email for the username "test@user.com" in the app "sally"
     Then I should get status "The user has already been validated"

  Scenario: Attempting validate for an invalid app
    Given A locke server running locally
      And A fresh app "sally"
     When I validate for the app "foobar" and username "test@user.com" with the token "abc"
     Then I should get status "Could not find an app with the name 'foobar'"

  Scenario: Attempting validate for an invalid user
    Given A locke server running locally
      And A fresh app "sally"
     When I validate for the app "sally" and username "test@user.com" with the token "abc"
     Then I should get status "There is no user with the email 'test@user.com' for the app 'sally'"

  Scenario: Attempting to validate a user that has already been validated
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I validate for the app "sally" and username "test@user.com" with the last emailed token
     When I validate for the app "sally" and username "test@user.com" with the last emailed token
     Then I should get status "The user has already been validated"

  Scenario: Attempting to validate a user with an invalid token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I validate for the app "sally" and username "test@user.com" with the token "abc"
     Then I should get status "Incorrect token"

  Scenario: Attempting to validate a user that has already been validated using a garbage token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I validate for the app "sally" and username "test@user.com" with the last emailed token
     When I validate for the app "sally" and username "test@user.com" with the token "abc"
     Then I should get status "The user has already been validated"

  Scenario: Using the last of two generated tokens
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I validate for the app "sally" and username "test@user.com" with the last emailed token
     Then I should get status "OK"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I should get a validation status of "true"

  Scenario: Using the first of two generated tokens
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I validate for the app "sally" and username "test@user.com" with the last emailed token
     Then I should get status "OK"
      And I authenticate for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I should get a validation status of "true"

  Scenario: Attempting to validate using a regular authentication token instead of a validation token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
     When I validate for the app "sally" and username "test@user.com" with the last token
     Then I should get status "Incorrect token"

  Scenario: Attempting to validate using another users validation token
    Given A locke server running locally
      And A fresh app "sally"
      And I create a user for the app "sally" with the username "test@user.com" and password "pwwpas"
      And I request a validation email for the username "test@user.com" in the app "sally"
      And I should get an email at "test@user.com"
      And The last email should contain a valid token
      And I create a user for the app "sally" with the username "test2@user.com" and password "pwwpas"
      And I request a validation email for the username "test2@user.com" in the app "sally"
      And I should get an email at "test2@user.com"
      And The last email should contain a valid token
     When I validate for the app "sally" and username "test@user.com" with the last token
     Then I should get status "Incorrect token"
