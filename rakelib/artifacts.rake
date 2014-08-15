def staging
  "build/staging"
end

namespace "artifact" do
  require "logstash/environment"
  package_files = [
    "LICENSE",
    "CHANGELOG",
    "CONTRIBUTORS",
    "{bin,lib,spec,locales}/{,**/*}",
    "vendor/elasticsearch/**/*",
    "vendor/collectd/**/*",
    "vendor/jruby/**/*",
    File.join(LogStash::Environment.gem_home.gsub(Dir.pwd + "/", ""), "{gems,specifications}/**/*"),
    "Rakefile",
    "rakelib/*",
  ]
  # TODO(sissel): vendor:geoip
  # TODO(sissel): vendor:useragent
  # TODO(sissel): vendor:kibana
  
  desc "Build a tar.gz of logstash with all dependencies"
  task "tar" => ["vendor:elasticsearch", "vendor:collectd", "vendor:jruby", "vendor:gems"] do
    Rake::Task["dependency:archive-tar-minitar"].invoke
    require "zlib"
    require "archive/tar/minitar"
    require "logstash/version"
    tarpath = "build/logstash-#{LOGSTASH_VERSION}.tar.gz"
    tarfile = File.new(tarpath, "wb")
    gz = Zlib::GzipWriter.new(tarfile, Zlib::BEST_COMPRESSION)
    tar = Archive::Tar::Minitar::Output.new(gz)
    package_files.each do |glob|
      Rake::FileList[glob].each do |path|
        Archive::Tar::Minitar.pack_file(path, tar)
      end
    end
    tar.close
    gz.close
    puts "Complete: #{tarpath}"
  end

  desc "Build an RPM of logstash with all dependencies"
  task "rpm" do
  end

  desc "Build an RPM of logstash with all dependencies"
  task "deb" do
  end
end

