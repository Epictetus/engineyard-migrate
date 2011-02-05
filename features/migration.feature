Feature: Migration
  In order to reduce cost of migrating from Heroku to AppCloud
  As a developer
  I want to migrate as much of my Heroku-hosted application to AppCloud

  Scenario: Migrate a simple app
    Given I have setup my SSH keys
    And I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"

    And I have setup my Heroku credentials
    And I have a Heroku application "heroku2ey-simple-app"
    And it has production data
    When I visit the application at "heroku2ey-simple-app.heroku.com"
    Then I should see table
      | People |
      | Dr Nic |
      | Danish |

    Given I have setup my AppCloud credentials
    And I reset the AppCloud application "heroku2eysimpleapp" database
    When I visit the application at "ec2-50-17-248-148.compute-1.amazonaws.com"
    Then I should see table
      | People |

    When I run local executable "heroku2ey" with arguments "migrate . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see "Migration complete!"
    When I visit the application at "ec2-50-17-248-148.compute-1.amazonaws.com"
    Then I should see table
      | People |
      | Dr Nic |
      | Danish |
    And port "3306" on "ec2-50-17-248-148.compute-1.amazonaws.com" should be closed
  
  Scenario: Fail if application isn't on Heroku
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    When I run local executable "heroku2ey" with arguments "migrate . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see
      """
      'heroku2ey migrate' is for migrating heroku applications.
      """
  
  Scenario: Fail if Heroku credentials not available
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    When I run local executable "heroku2ey" with arguments "migrate . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see
      """
      Please setup your local Heroku credentials first.
      """
  
  Scenario: Fail if no Git 'origin' repo URI
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    And I have setup my SSH keys
    And I have setup my Heroku credentials
    Given I run executable "git" with arguments "remote rm origin"
    When I run local executable "heroku2ey" with arguments "migrate . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see
      """
      Please host your Git repo externally and add as remote 'origin'.
      """
  
  Scenario: Fail if AppCloud credentials not available
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    And I have setup my SSH keys
    And I have setup my Heroku credentials

    When I run local executable "heroku2ey" with arguments "migrate . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see
      """
      Please create, boot and deploy an AppCloud application for git@github.com:engineyard/heroku2ey-simple-app.git.
      """
  
  Scenario: Fail if no AppCloud environments/applications match this application
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    And I have setup my SSH keys
    And I have setup my Heroku credentials

    Given I have setup my AppCloud credentials
    And I run executable "git" with arguments "remote rm origin"
    And I run executable "git" with arguments "remote add origin git@github.com:engineyard/UNKNOWN.git"
    
    When I run local executable "heroku2ey" with arguments "migrate ."
    Then I should see
      """
      Please create, boot and deploy an AppCloud application for git@github.com:engineyard/UNKNOWN.git.
      """

