Feature: Pages
  In order to maintain and read pages
  As a user
  I want list, browse, read, and edit pages

  Background:
    Given the default user set
    And the following default pages
      | title  | body                 | show_in_menu | is_template | is_draft | interpreter |
      | Page 1 | Lorem ipsum          | true         | false       | false    | :markdown   |
      | Page 2 | Lirum Opsim          | false        | false       | false    | :markdown   |
      | Page T | This is a Template   | false        | true        | false    | :markdown   |
      | Page D | This is a Draft      | false        | false       | true     | :markdown   |
    And I am logged in as user "admin@iboard.cc" with password "thisisnotsecret"

  Scenario: Pages with 'show_in_menu' should be on the menu-bar
    Given I am on the pages page
    Then I should see "Page 1" within "#session"
    And I should not see "Page 2" within "#session"

  Scenario: A page should be shown when clicking read from the index
    Given I am on the pages page
    And I click on link "Read"
    Then I should be on the permalink_path of "Page 1"
    And I should see "Page 1"
    And I should see "Lorem ipsum"

  Scenario: Admin should be able to delete a page
    Given I am on the pages page
    And I click on link "Delete"
    Then I should be on the pages page
    And I should not see "Page 1"

  Scenario: Admin should be able to create a new page and this page should be rendered with textile
    Given I am on the pages page
    And I click on link "Create a new Page"
    And I fill in "Title" with "Page 3"
    And I fill in "Body" with "h1. Page three body"
    And I uncheck "page_is_draft"
    And I click on "Create Page"
    Then I should be on the page path of "Page 3"
    And I should see "successfully created"
    And I should see "Page 3"
    And I should see "Page three body" within "#container"
    And I should see "Page 3" within "#session"

  Scenario: It should not be able to save a page with no title
    Given I am on the pages page
    And I click on link "Create a new Page"
    And I fill in "Body" with "h1. Page three body"
    And I uncheck "page_is_draft"
    And I click on "Create Page"
    Then I should see "Create a new Page" within "#container"
    And I should see "can't be blank"

  Scenario: It should not be able to save a page without a body
    Given I am on the pages page
    And I click on link "Create a new Page"
    And I fill in "Title" with "Page three body"
    And I uncheck "page_is_draft"
    And I click on "Create Page"
    Then I should see "Create a new Page" within "#container"
    And I should see "can't be blank"

  Scenario: Moderator/Admin should be able to edit a page
    Given I am on the pages page
    And I click on link "Edit"
    Then I should be on the edit page for "Page 1"
    And I should see "Editing page"

  Scenario: Moderator/Admin should be able to modify a page
    Given I am on the edit page for "Page 1"
    And I fill in "Title" with "This is Page 1, modified"
    And I fill in "Body" with "Cucumber tests rock!"
    And I uncheck "page_is_draft"
    And I click on "Update Page"
    Then I should be on the page path of "This is Page 1, modified"
    And I should see "This is Page 1, modified"
    And I should see "Cucumber tests rock!"
    And I should see "Page was successfully updated."
    And I should not see "Error"

  Scenario: "A Page should be commentable"
    Given I am on the page path of "Page 1"
    And I fill in "Comment" with "And here my comment for this page"
    And I click on "Post comment"
    Then I should be on the page path of "Page 1"
    And I should see "Comment successfully created. You can edit it for the next"
    And I should see "And here my comment for this page"

  Scenario: Pagination should work on pages::index
    pending

  Scenario: Page title and body should be translated
    Given the following translated pages
      | title_en  | body_en      | title_de     | body_de    |
      | GB        | Fish n chips | Deutschland  | Sauerkraut |
    And I am on the page path of "GB"
    And I click on link "locale_de"
    Then I should see "Sauerkraut"
    Then I click on link "locale_en"
    Then I should see "Fish n chips"
    Then the default locale

  Scenario: Page index should not include Template-Pages
    Given I am on the pages page
    Then I should not see "Page T"

  Scenario: Authors should be able to derive new pages (articles) from pages where is_template is true
    Given I am on the new_article page
    Then I should see "Choose a template"
    And I select "Page T" from "page_template_id" within ".field"
    And I click on "Create"
    And I fill in "page_title" with "This is a filled Page Template" within "#container_main form"
    And I fill in "page_body" with "This is a filled page body" within "#container_main form"
    And I uncheck "page_is_draft" within "#container_main form"
    And I click on "Create Page"
    Then I should see "This is a filled Page Template"
    And I should see "This is a filled page body"

  Scenario: A derived page should save it's template
    Given I am on the new_article page
    Then I should see "Choose a template"
    And I select "Page T" from "page_template_id" within "#container_main form"
    And I click on "Create"
    And I fill in "page_title" with "Derived Page" within "#container_main form"
    And I fill in "page_body" with "This is derived from Page T" within "#container_main form"
    And I uncheck "page_is_draft" within "#container_main form"
    And I click on "Create Page"
    Then I should see "Page was successfully created"
    And I click on link "Derived from Page T" within "#container"
    Then I should see "Page T"
    And I should see "This is a Template"

  Scenario: Admins should be able to list template pages
    Given I am on the edit page template for "Page T"
    Then I should see "This is a Template"

  Scenario: The page/templates index should provide a link to create a new article for each template
    Given I am on the templates_pages page
    And I click on link "Create new article" within ".page_template"
    Then I should be on the create_new_article_pages page
    And I should see "Page T"

  Scenario: Draft pages should not be displayed if not in draft-mode
    Given I am logged out
    And I am on page path of "Page D"
    Then I should be on the pages page
    Then I should see "Listing pages"
    And I should not see "Page D"
