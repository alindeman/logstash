
task "test" => [ "dependency:gems" ] do
  require 'rspec/core'
  RSpec::Core::Runner.run(Rake::FileList["spec/**/*.rb"])
end

task "wtf" do
  puts `gem env`
  puts `gem list`
  require "rack"
end
