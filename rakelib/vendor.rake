
DOWNLOADS = {
  "elasticsearch" => { "version" => "1.3.0", "sha1" => "" },
  "collectd" => { "version" => "5.4.0", "sha1" => "a90fe6cc53b76b7bdd56dc57950d90787cb9c96e" },
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
  task "elasticsearch" do |task, args|
    info = DOWNLOADS[task.name]
    version = info["version"]
    sha1 = info["sha1"]
  end

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
          fd.write(chunk) while chunk = entry.read(16384)
        end # File.open
      end # untar
    end.invoke
  end
end
