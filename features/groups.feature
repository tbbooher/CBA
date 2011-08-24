Feature: PolcoGroups
  In order to allow users to track and compare votes
  As a user who has registered and joined groups
  I want to provide the ability to join, follow and manage groups

  Background:
    Given the following user records
      | email           | name    | roles_mask | password        | password_confirmation | confirmed_at        |
      | user@iboard.cc  | testmax | 1          | thisisnotsecret | thisisnotsecret       | 2010-01-01 00:00:00 |
      | guest@iboard.cc | guest   | 0          | thisisnotsecret | thisisnotsecret       | 2010-01-01 00:00:00 |
      | admin@iboard.cc | admin   | 5          | thisisnotsecret | thisisnotsecret       | 2010-01-01 00:00:00 |
      | staff@iboard.cc | staff   | 4          | thisisnotsecret | thisisnotsecret       | 2010-01-01 00:00:00 |
      | reg@iboard.cc   | reggie  | 6          | thisisnotsecret | thisisnotsecret       | 2010-01-01 00:00:00 |
    And I am logged in as user "admin@iboard.cc" with password "thisisnotsecret"
    Given bills are loaded
#    And the following polco group records
#      | name | type |
#      | polco founders  | :custom |
#      | OH              | :state  |
#      | OH08            | :district |
#      | Dan Cone        | :common   |
#      | USA             | :country  |

  Scenario: I should be able to see a groups management page
    Given I sign out
    And I am logged in as user "reg@iboard.cc" with password "thisisnotsecret"
    When I am on the groups management page
    Then I should see "bills"
    







