if RUBY_ENGINE != "jruby"
  puts "Restarting myself under JRuby (currently #{RUBY_ENGINE} #{RUBY_VERSION})"
  Rake::Task["vendor:jruby"].invoke
  exec("java", "-jar", "vendor/jruby/jruby-complete-1.7.13.jar", "-S", "rake", *ARGV)
end

