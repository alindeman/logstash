
namespace "dependency" do
  task "bundler" do
    begin
      # Special handling because "gem 'bundler', '>=1.3.5'" will fail if
      # bundler is already loaded.
      require "bundler/cli"
    rescue LoadError
      Rake::Task["gem:require"].invoke("bundler", ">= 1.3.5", ENV["GEM_HOME"])
      require "bundler/cli"
    end
    require_relative "bundler_patch"
  end

  task "gems" => [ "bundler" ] do
    puts "Ensuring gems are correct in #{ENV["GEM_HOME"]}"
    puts LogStash::Environment.gem_target
    Rake::Task["dependency:rbx-stdlib"] if LogStash::Environment.ruby_engine == "rbx"

    # Try installing a few times in case we hit the "bad_record_mac" ssl error during installation.
    10.times do
      begin
        Bundler::CLI.start(["install", "--gemfile=tools/Gemfile", "--path", LogStash::Environment.gem_target, "--clean", "--without", "development"])
        break
      rescue Gem::RemoteFetcher::FetchError => e
        puts e.message
        puts e.backtrace.inspect
        sleep 5 #slow down a bit before retry
      end
    end
  end # task gems

  task "rbx-stdlib" do
    Rake::Task["gem:require"].execute("rubysl", ">= 0", ENV["GEM_HOME"])
  end # task rbx-stdlib
end # namespace dependency
