Feature: Rake tasks scoped to the next Baltix command

   Background:
      Given a temporary Rake project
      And the project has versioned Rake tasks for the CLI

   Scenario: Preserve command order, option scope and repeated actions
      When the ordered Baltix commands are executed:
         """
         --rake-task-before=first --packager-name=First --output-file=$PROJECT/first.spec spec
         --rake-task-before=second --packager-name=Second --output-file=$PROJECT/second.spec spec
         --output-file=$PROJECT/third.spec spec
         """
      Then the ordered CLI succeeds
      And the generated CLI specs contain:
         | file        | line                        |
         | first.spec  | Version:       1.0.0        |
         | first.spec  | Packager:      First <>     |
         | second.spec | Version:       2.0.0        |
         | second.spec | Packager:      Second <>    |
         | third.spec  | Version:       2.0.0        |
      And the CLI Rake tasks ran in this order:
         | first  |
         | second |

   Scenario: An option after a command applies to the following command
      When the ordered Baltix commands are executed:
         """
         --output-file=$PROJECT/before.spec spec
         --rake-task-before=first --output-file=$PROJECT/after.spec spec
         """
      Then the ordered CLI succeeds
      And the generated CLI specs contain:
         | file        | line                 |
         | before.spec | Version:       0.0.0 |
         | after.spec  | Version:       1.0.0 |
      And the CLI Rake tasks ran in this order:
         | first |

   Scenario: Execute a task list once in its declared order
      When the ordered Baltix commands are executed:
         """
         --rake-task-before=first,second,first --output-file=$PROJECT/result.spec spec
         """
      Then the ordered CLI succeeds
      And the generated CLI specs contain:
         | file        | line                 |
         | result.spec | Version:       2.0.0 |
      And the CLI Rake tasks ran in this order:
         | first  |
         | second |

   Scenario: Configured tasks are consumed by the first command
      Given the configured rake_task_before list is "first"
      When the ordered Baltix commands are executed:
         """
         --output-file=$PROJECT/first.spec spec --output-file=$PROJECT/second.spec spec
         """
      Then the ordered CLI succeeds
      And the generated CLI specs contain:
         | file        | line                 |
         | first.spec  | Version:       1.0.0 |
         | second.spec | Version:       1.0.0 |
      And the CLI Rake tasks ran in this order:
         | first |

   Scenario: An explicit CLI task list replaces the configured list
      Given the configured rake_task_before list is "first"
      When the ordered Baltix commands are executed:
         """
         --rake-task-before=second --output-file=$PROJECT/result.spec spec
         """
      Then the ordered CLI succeeds
      And the generated CLI specs contain:
         | file        | line                 |
         | result.spec | Version:       2.0.0 |
      And the CLI Rake tasks ran in this order:
         | second |

   Scenario: A failed task stops its actor and subsequent commands
      When the ordered Baltix commands are executed:
         """
         --rake-task-before=fail --output-file=$PROJECT/first.spec spec
         --rake-task-before=second --output-file=$PROJECT/second.spec spec
         """
      Then the ordered CLI fails with "generation failed"
      And no CLI spec files are written
      And the CLI Rake tasks ran in this order:
         | fail |

   Scenario: An unknown task stops the actor
      When the ordered Baltix commands are executed:
         """
         --rake-task-before=absent --output-file=$PROJECT/result.spec spec
         """
      Then the ordered CLI fails with "Rake tasks not found: absent"
      And no CLI spec files are written

   Scenario: A task option requires a following command
      When the ordered Baltix commands are executed:
         """
         --output-file=$PROJECT/result.spec spec --rake-task-before=first
         """
      Then the ordered CLI fails with "following command for --rake-task-before"
      And no CLI spec files are written

   Scenario: The obsolete spec option is not a CLI alias
      When the ordered Baltix commands are executed:
         """
         --pre=first --output-file=$PROJECT/result.spec spec
         """
      Then the ordered CLI fails with "invalid option: --pre=first"
      And no CLI spec files are written

   Scenario: Find nested Rakefiles while honoring the existing source path filters
      Given the root Rakefile is moved into "component"
      And the Rake project file "fixtures/Rakefile" is:
         """
         task :first do
           raise 'ignored fixture was executed'
         end
         """
      When the ordered Baltix commands are executed:
         """
         --rake-task-before=first --output-file=$PROJECT/result.spec spec
         """
      Then the ordered CLI succeeds
      And the CLI Rake tasks in "component" ran in this order:
         | first |
