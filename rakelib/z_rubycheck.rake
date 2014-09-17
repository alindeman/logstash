if RUBY_ENGINE != "jruby"
  puts "Restarting myself under JRuby (currently #{RUBY_ENGINE} #{RUBY_VERSION})" if $DEBUG

  # Make sure we have JRuby, then rerun ourselves under jruby.
  Rake::Task["vendor:jruby"].invoke
  jar = File.join("vendor", "jruby", "jruby-complete-#{DOWNLOADS["jruby"]["version"]}.jar") 
  exec("java", "-jar", jar, "-S", "rake", *ARGV)
end

