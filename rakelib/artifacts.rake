def staging
  "build/staging"
end

def append_tar(tar, *source)
  puts source
  Rake::FileList[*source].each do |path|
    info = File.lstat(path)
    mode = info.executable? ? 0755 : 0644
    if info.directory?
      tar.mkdir(path, :mode => mode)
    else
      File.open(path, "rb") do |input|
        tar.add_file_simple(path, :mode => mode, :size => info.size, :mtime => info.mtime.to_i) do |output|
          IO.copy_stream(input, output)
        end
      end
    end
  end
end

namespace "artifact" do
  # TODO(sissel): vendor:geoip
  # TODO(sissel): vendor:useragent
  # TODO(sissel): vendor:jruby
  # TODO(sissel): vendor:kibana
  

  vendor_copy_re = Regexp.new(Regexp.quote("#{staging}/") + "(?<path>vendor/.*)")
  source_proc = proc { |t| vendor_copy_re.match(t)["path"] }
  rule vendor_copy_re => [staging, source_proc] do |task|
    target = task.name
    source = source_proc.call(target)
    target_dir = File.dirname(target)
    mkdir_p target_dir if !File.directory?(target_dir)
    if File.directory?(source)
      mkdir target
    else
      cp source, target
    end
  end

  desc "Build a tarball of logstash with all dependencies"
  task "tarball" => ["vendor:elasticsearch", "vendor:collectd", "vendor:jruby", "vendor:gems"] do
    Rake::Task["dependency:archive-tar-minitar"].invoke
    require "zlib"
    require "archive/tar/minitar"
    require "logstash/version"
    tarpath = "build/logstash-#{LOGSTASH_VERSION}.tar.gz"
    tarfile = File.new(tarpath, "wb")
    gz = Zlib::GzipWriter.new(tarfile, Zlib::BEST_COMPRESSION)
    tar = Archive::Tar::Minitar::Writer.new(gz)

    append_tar(tar, "{bin,lib,spec,locales}/{,**/*}", "LICENSE")
    append_tar(tar, "vendor/elasticsearch/**/*")
    append_tar(tar, "vendor/collectd/**/*")
    append_tar(tar, "vendor/jruby/**/*")
    gems = File.join(LogStash::Environment.gem_home.gsub(Dir.pwd + "/", ""), "{gems,specifications}/**/*")
    append_tar(tar, gems)
    tar.close
    gz.close
    #tarfile.close
    puts "Complete: #{tarpath}"
  end

  desc "Build an RPM of logstash with all dependencies"
  task "rpm" do
  end

  desc "Build an RPM of logstash with all dependencies"
  task "deb" do
  end
end

