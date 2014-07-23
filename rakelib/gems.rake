require "rubygems/specification"
require "rubygems/commands/install_command"
require "logstash/JRUBY-PR1448" if RUBY_PLATFORM == "java" && Gem.win_platform?

namespace "gem" do
  task "require", :name, :requirement, :target do |task, args|
    name, requirement, target = args[:name], args[:requirement], args[:target]
    begin
      gem name, requirement
      puts "Gem #{name} found"
    rescue Gem::LoadError => e
      puts "Failed to load #{name} #{requirement}: #{e}"
      Rake::Task["gem:install"].invoke(name, requirement, target)
    end
    task.reenable # Allow this task to be run again
  end

  task "install", :name, :requirement, :target do |task, args|
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

    task.reenable # Allow this task to be run again
  end # task "install"
end # namespace "gem"
