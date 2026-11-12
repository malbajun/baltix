Feature: Execute complete Rake tasks inside Baltix's Ruby process

   Scenario Outline: Restore the caller's Rake context after metadata import
      - retain the application's tasks when source Rakefiles are inspected, as in Rails
      - restore the caller even when the imported metadata raises an exception
      - keep the imported application's tasks available to the metadata reader
      Given a temporary Rake project
      And the Rake project file "Rakefile" is:
         """
         Rake::Task.define_task(:imported_metadata)
         <finish>
         """
      When the project Rake metadata is read
      Then the caller's Rake application and directory are restored
      And the caller's metadata marker task is retained
      And the imported Rake metadata contains its own task

      Examples:
         | finish                   |
         | nil                      |
         | raise 'metadata failure' |

   Scenario Outline: Execute imported task prerequisites with the correct application and directory
      Given a temporary Rake project
      And the Rake project file "Rakefile" is:
         """
         import 'tasks.rake'
         task :prepare do
           File.write('result.txt', "prepare\n")
         end
         """
      And the Rake project file "tasks.rake" is:
         """
         task :generate => :prepare do
           File.open('result.txt', 'a') { |file| file.puts "generate:#{Process.pid}" }
         end
         """
      When the project Rake task "<task>" is executed
      Then the Rake task succeeds
      And the project task result is generated inside the current Ruby process
      And the caller's Rake application and directory are restored

      Examples:
         | task      |
         | generate  |
         | @generate |

   Scenario: Use real plugin tasks while restoring metadata adapters between runs
      Given a temporary Rake project
      And the Hoe metadata adapter is loaded
      And the Rake project file "hoe.rb" is:
         """
         require 'rake/clean'
         class Hoe
           def self.spec(name)
             CLEAN.include 'obsolete'
             Rake::Task.define_task(:lexer) { File.write('result.txt', "prepare\ngenerate:#{Process.pid}\n") }
           end
         end
         """
      And the Rake project library directory is on the load path
      And the Rake project file "Rakefile" is:
         """
         require 'hoe'
         Hoe.spec 'example'
         task :generate => :lexer
         """
      When the project Rake task "generate" is executed
      Then the Rake task succeeds
      And the project task result is generated inside the current Ruby process
      And the Hoe metadata adapter is restored
      When the project Rake task "generate" is executed
      Then the Rake task succeeds
      And the Hoe metadata adapter is restored
      And the caller's Rake application and directory are restored

   Scenario: Propagate task failures and restore the caller's context
      Given a temporary Rake project
      And the Rake project file "Rakefile" is:
         """
         task :generate do
           raise 'generation failed'
         end
         """
      When the project Rake task "generate" is executed
      Then the Rake task fails with "generation failed"
      And the caller's Rake application and directory are restored

   Scenario: Recreate cached cleaning tasks in the active application
      Given a temporary Rake project
      And the caller has already loaded Rake cleaning tasks
      And the Rake project file "obsolete" is:
         """
         remove this file
         """
      And the Rake project file "Rakefile" is:
         """
         require 'rake/clean'
         CLEAN.include 'obsolete'
         task :generate => :clean
         """
      When the project Rake task "generate" is executed
      Then the Rake task succeeds
      And the obsolete project file is removed
      And the caller's cleaning list is restored
      And the caller's Rake application and directory are restored

   Scenario: Finish parallel workers before restoring context after a task failure
      Given a temporary Rake project
      And the Rake project file "Rakefile" is:
         """
         started = Queue.new
         Rake.application.options.thread_pool_size = 2
         task :worker do |task|
           started << true
           sleep 0.05
           context = "#{Rake.application.equal?(task.application)}:#{Dir.pwd == __dir__}"
           File.write(File.join(__dir__, 'worker-context'), context)
         end
         task(:fail) { started.pop; raise 'generation failed' }
         multitask :generate => [:worker, :fail]
         """
      When the project Rake task "generate" is executed
      Then the Rake task fails with "generation failed"
      And the parallel worker retained its Rake context
      And the caller's Rake application and directory are restored
