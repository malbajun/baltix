module CollectLoaderOutputWrappers
   def load_file(*args)
      result = super
      GC.start if Thread.current[:baltix_test_loader_gc]
      result
   end
end

Baltix::Loader::Certain.prepend(CollectLoaderOutputWrappers)

Around('@loader_gc') do |_scenario, run|
   previous = Thread.current[:baltix_test_loader_gc]
   Thread.current[:baltix_test_loader_gc] = true
   run.call
ensure
   Thread.current[:baltix_test_loader_gc] = previous
end

Then('the main source metadata file is {string}') do |file|
   expect(File.basename(space.main_source.source_file)).to eql(file)
end
