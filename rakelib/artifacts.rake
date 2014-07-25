
namespace "artifact" do
  # TODO(sissel): vendor:geoip
  # TODO(sissel): vendor:useragent
  # TODO(sissel): vendor:jruby
  # TODO(sissel): vendor:kibana
  
  # take build/staging
  # vendor/ except for the '_' directory
  # tar it up.
  task "tarball" => ["build:copy", "vendor:elasticsearch", "vendor:collectd"] do
  end

  task "rpm" do
  end

  task "deb" do
  end
end

