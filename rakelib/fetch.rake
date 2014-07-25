def fetch(url, sha1, output)
  require "net/http"
  require "uri"
  require "digest/sha1"

  puts "Downloading #{url}"
  actual_sha1 = download(url, output)

  if actual_sha1 != sha1
    fail "SHA1 does not match (expected '#{sha1}' but got '#{actual_sha1}')"
  end
end # def fetch

directory "vendor/_" => ["vendor"] do |task, args|
  mkdir task.name
end

def file_fetch(url, sha1)
  filename = File.basename(URI(url).path)
  output = "vendor/_/#{filename}"
  task output => [ "vendor/_" ] do
    begin
      actual_sha1 = file_sha1(output)
      if actual_sha1 != sha1
        fetch(url, sha1, output)
      end
    rescue Errno::ENOENT
      fetch(url, sha1, output)
    end
  end

  return output
end

def file_sha1(path)
  digest = Digest::SHA1.new
  fd = File.new(path, "r")
  while true
    begin
      digest << fd.sysread(16384)
    rescue EOFError
      break
    end
  end
  return digest.hexdigest
ensure
  fd.close if fd
end

def download(url, output)
  uri = URI(url)
  digest = Digest::SHA1.new
  tmp = "#{output}.tmp"
  Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == "https")) do |http|
    request = Net::HTTP::Get.new(uri)
    http.request(request) do |response|
      fail "HTTP fetch failed for #{url}. #{response}" if response.code != "200"
      response.each_header do |h,v|
        p h => v
      end
      File.open(tmp, "w") do |fd|
        response.read_body do |chunk|
          fd.write(chunk)
          digest << chunk
        end
      end
    end
  end

  File.rename(tmp, output)

  return digest.hexdigest
rescue SocketError => e
  puts "Failure while downloading #{url}: #{e}"
  raise
ensure
  File.unlink(tmp) if File.exist?(tmp)
end # def download
