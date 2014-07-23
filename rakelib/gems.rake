require "rubygems/specification"
require "rubygems/commands/install_command"
require "logstash/JRUBY-PR1448" if RUBY_PLATFORM == "java" && Gem.win_platform?

namespace "gem" do
  task "require", :name, :requirement do |task, args|
    name, requirement, target = args[:name], args[:requirement], args[:target]
    begin
      gem name, requirement
    rescue Gem::LoadError => e
      Rake::Task["gem:install"].invoke(name, requirement, target)
    end
  end

  task "install", :name, :requirement do |task, args|
    name, requirement, target = args[:name], args[:requirement], args[:target]
    puts "Fetching and installing gem: #{name} (#{requirement})"

    installer = Gem::Commands::InstallCommand.new
    installer.options[:generate_rdoc] = false
    installer.options[:generate_ri] = false
    installer.options[:version] = requirement
    installer.options[:args] = [name]
    installer.options[:install_dir] = target

    # ruby 2.0.0 / rubygems 2.x; disable documentation generation
    installer.options[:document] = []
    begin
      installer.execute
    rescue Gem::SystemExitException => e
      if e.exit_code != 0
        puts "Installation of #{name} failed"
        raise
      end
    end
  end # task "install"

  task "bundler" do
    # Ensure bundler is available.
    begin
      gem("bundler", ">=1.3.5")
    rescue Gem::LoadError => e
      Rake::Task["gem:install"].invoke("bundler", ">= 1.3.5")
    end
  end
end # namespace "gem"
