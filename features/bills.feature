Feature: Bills
  In order to participate in the political process
  As a user who has registered with their zip+4
  I want list and vote on Bills

Background:
    Given the following user records
      | email            | name      | roles_mask | password         | password_confirmation | confirmed_at         |
      | user@iboard.cc   | testmax   | 1          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
      | guest@iboard.cc  | guest     | 0          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
      | admin@iboard.cc  | admin     | 5          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
      | staff@iboard.cc  | staff     | 4          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
    And I am logged in as user "admin@iboard.cc" with password "thisisnotsecret"
    Given the following bill records
      | govtrack_id | titles |
      | h112-1723   | [["short", "H Bill"], ["official", "House bill."]] |
      | s112-536    | [["short", "S Bill"], ["official", "Senate bill."]] |

Scenario: Non-admins and non-staff users should not be able to vote
  Given I sign out
  And I am logged in as user "guest@iboard.cc" with password "thisisnotsecret"
  When I go to path "/bills"
  Then I should see "H Bill"
  # then they should not see the voting button
  #And I follow







