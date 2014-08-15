if RUBY_ENGINE != "jruby"
  puts "Re-executing myself through JRuby"
  Rake::Task["vendor:jruby"].invoke
  exec("java", "-jar", "vendor/jruby/jruby-complete-1.7.13.jar", "-S", "rake", *ARGV)
end

