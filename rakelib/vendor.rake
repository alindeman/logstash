ELASTICSEARCH_VERSION = "1.1.1"

def vendor(name)
  return File.join("vendor", name)
end


#directory "vendor" do |task,args|
  #mkdir task.name
#end

namespace "vendor" do
  task "elasticsearch", :version do |task, args|
    version = args[:version]
    output = vendor("elasticsearch")
    fail "Elasticsearch version not specified." if version.nil?

  end


  task "collectd", :version do |task, args|
    version = "5.4.0"
    sha1 = "a90fe6cc53b76b7bdd56dc57950d90787cb9c96e"
    url = "https://collectd.org/files/collectd-#{version}.tar.gz"
    download = file_fetch(url, sha1)

    Rake::Task[download].invoke

    # Extract typesdb
    system("tar", "-zxf", download, "-O", "collectd-#{version}/src/types.db")
  end
end
