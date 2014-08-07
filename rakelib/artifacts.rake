
namespace "artifact" do
  # TODO(sissel): vendor:geoip
  # TODO(sissel): vendor:useragent
  # TODO(sissel): vendor:jruby
  # TODO(sissel): vendor:kibana
  
  desc "Build a tarball of logstash with all dependencies"
  task "tarball" => ["build:copy", "vendor:elasticsearch", "vendor:collectd"] do
  end

  desc "Build an RPM of logstash with all dependencies"
  task "rpm" do
  end

  desc "Build an RPM of logstash with all dependencies"
  task "deb" do
  end
end

