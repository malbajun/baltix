@actor @spec
Feature: Space

   Scenario: Space root validation
      Given space file:
         """
         ---
         rootdir: "/path/to/dot/space"
         """

      When developer loads the space
      Then he sees that space's "rootdir" is a "/path/to/dot/space"

   Scenario Outline: Ignore test directories relative to the project root
      Given blank space
      When he sets the space option "rootdir" to fixture "turn"
      Then a source at "<path>" is <status>

      Examples:
         | path                           | status    |
         | turn.gemspec                   | enabled   |
         | test/fixtures/example.gemspec  | disabled  |
         | tests/Gemfile                  | disabled  |
         | kitchen-tests/Gemfile          | disabled  |
         | integration_tests/Gemfile      | disabled  |
         | testdata/Gemfile               | disabled  |
         | ruby-testdata/Gemfile          | disabled  |
         | library.testdata/Gemfile       | disabled  |
         | contests/Gemfile               | enabled   |
         | testdatabase/Gemfile           | enabled   |
         | lib/tests.rb                   | enabled   |

   Scenario Outline: Explicitly regard a test directory when it is needed
      Given blank space
      When he sets the space option "rootdir" to fixture "turn"
      And he sets the space options as:
         | options               | value     |
         | regarded_path_tokens  | [<token>] |
      Then a source at "<path>/Gemfile" is enabled

      Examples:
         | token           | path            |
         | tests           | tests           |
         | kitchen-tests   | kitchen-tests   |
         | testdata        | testdata        |
         | ruby-testdata   | ruby-testdata   |

   Scenario: A source without a version remains available
      Given blank space
      When he sets the space option "rootdir" to fixture "ruby-gnome2"
      Then a versionless source at "Gemfile" is enabled

