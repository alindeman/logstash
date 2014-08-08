def staging
  "build/staging"
end

namespace "artifact" do
  # TODO(sissel): vendor:geoip
  # TODO(sissel): vendor:useragent
  # TODO(sissel): vendor:jruby
  # TODO(sissel): vendor:kibana
  
  desc "Build a tarball of logstash with all dependencies"

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

  task "tarball" => ["build:copy", "vendor:elasticsearch", "vendor:collectd", "vendor:gems"] do
    # copy vendor things to build/staging/vendor/<vendor>
    %w(elasticsearch collectd bundle).each do |vendor|
      sources = Rake::FileList["vendor/#{vendor}/**/*"].reject { |s| s =~ /\.gitignore$/ }
      sources.each do |source|
        Rake::Task[File.join(staging, source)].invoke
      end
    end
  end

  desc "Build an RPM of logstash with all dependencies"
  task "rpm" do
  end

  desc "Build an RPM of logstash with all dependencies"
  task "deb" do
  end
end

