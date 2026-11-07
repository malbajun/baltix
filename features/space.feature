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

   Scenario: Ignore source directories relative to the project root
      Given blank space
      When he sets the space option "rootdir" to fixture "turn"
      Then a source at "turn.gemspec" is enabled
      And a source at "test/fixtures/example.gemspec" is disabled

