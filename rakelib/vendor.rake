ELASTICSEARCH_VERSION = "1.1.1"

def vendor(name)
  return File.join("vendor", name)
end

namespace "vendor" do
  task "elasticsearch", :version do |task, args|
    version = args[:version]
    output = vendor("elasticsearch")
    fail "Elasticsearch version not specified." if version.nil?

  end
end
