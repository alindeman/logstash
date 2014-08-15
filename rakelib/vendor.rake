
DOWNLOADS = {
  "elasticsearch" => { "version" => "1.3.0", "sha1" => "f9e02e2cdcb55e7e8c5c60e955f793f68b7dec75" },
  "collectd" => { "version" => "5.4.0", "sha1" => "a90fe6cc53b76b7bdd56dc57950d90787cb9c96e" },
  "jruby" => { "version" => "1.7.13", "sha1" => "0dfca68810a5eed7f12ae2007dc2cc47554b4cc6" },
}

def vendor(*args)
  return File.join("vendor", *args)
end

def untar(tarball, &block)
  Rake::Task["dependency:archive-tar-minitar"].invoke
  require "archive/tar/minitar"
  tgz = Zlib::GzipReader.new(File.open(tarball))
  # Pull out typesdb
  tar = Archive::Tar::Minitar::Input.open(tgz)
  tar.each(&block)
end # def untar

namespace "vendor" do
  task "jruby" do |task, args|
    name = task.name.split(":")[1]
    info = DOWNLOADS[name]
    version = info["version"]
    url = "http://jruby.org.s3.amazonaws.com/downloads/#{version}/jruby-complete-#{version}.jar"

    download = file_fetch(url, info["sha1"])
    parent = vendor(name).gsub(/\/$/, "")
    directory parent => "vendor" do
      mkdir parent
    end.invoke unless Rake::Task.task_defined?(parent)
    
    file vendor(name, File.basename(download)) do |task, args|
      cp download, task.name
    end.invoke
  end # jruby

  task "elasticsearch" do |task, args|
    name = task.name.split(":")[1]
    info = DOWNLOADS[name]
    version = info["version"]
    url = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{version}.tar.gz"
    download = file_fetch(url, info["sha1"])

    parent = vendor(name).gsub(/\/$/, "")
    directory parent => "vendor" do
      mkdir parent
    end.invoke unless Rake::Task.task_defined?(parent)

    untar(download) do |entry|
      next unless entry.full_name =~ /\.jar$/
      path = vendor("elasticsearch", File.basename(entry.full_name))
      file path => parent do
        puts "Extracting #{entry.full_name} from #{download}"
        File.open(path, "w") do |fd|
          IO.copy_stream(entry, fd)
        end
      end.invoke # File.open
    end # untar
  end # task elasticsearch

  task "collectd" do |task, args|
    name = task.name.split(":")[1]
    info = DOWNLOADS[name]
    version = info["version"]
    sha1 = info["sha1"]
    url = "https://collectd.org/files/collectd-#{version}.tar.gz"

    download = file_fetch(url, sha1)

    parent = vendor(name).gsub(/\/$/, "")
    directory parent => "vendor" do
      mkdir parent
    end unless Rake::Task.task_defined?(parent)

    file vendor(name, "types.db") => [download, parent] do |task, args|
      next if File.exists?(task.name)
      untar(download) do |entry|
        next unless entry.full_name == "collectd-#{version}/src/types.db"
        puts "Writing #{task.name} from #{download}"
        File.open(task.name, "w") do |fd|
          IO.copy_stream(entry, fd)
        end # File.open
      end # untar
    end.invoke
  end

  task "gems" => [ "dependency:bundler" ] do
    require "logstash/environment"
    Rake::Task["dependency:rbx-stdlib"] if LogStash::Environment.ruby_engine == "rbx"
    Rake::Task["dependency:stud"].invoke

    # Skip bundler if we've already done this recently.
    donefile = File.join(LogStash::Environment.gem_target, ".done")
    if File.file?(donefile) 
      age = (Time.now - File.lstat(donefile).mtime)
      # Skip if the donefile was last modified recently
      next if age < 300
    end

    # Try installing a few times in case we hit the "bad_record_mac" ssl error during installation.
    10.times do
      begin
        Bundler::CLI.start(["install", "--gemfile=tools/Gemfile", "--path", LogStash::Environment.gem_target, "--clean", "--without", "development", "--jobs", 4])
        break
      rescue Gem::RemoteFetcher::FetchError => e
        puts e.message
        puts e.backtrace.inspect
        sleep 5 #slow down a bit before retry
      end
    end
    File.write(donefile, Time.now.to_s)
  end # task gems

end
