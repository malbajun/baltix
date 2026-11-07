Feature: Dependencies from real Ruby projects

   Scenario: Replace a development dependency version in digest-crc
      Given the dependency DSL from the "digest-crc" fixture Gemfile
      When the dependency requirement for "rspec" is replaced with "~> 3.12"
      Then the generated Gemfile declares "rspec" in group "development" with requirement "~> 3.12"
