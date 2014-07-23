def fetch(url, sha1, output)
  require "net/http"
  require "uri"
  require "digest/sha1"
  require "insist"

  uri = URI(url)
  digest = Digest::SHA1.new
  tmp = "#{output}.tmp"
  Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == "https")) do |http|
    request = Net::HTTP::Get.new(uri)
    http.request(request) do |response|
      File.open(output) do |fd|
        response.read_body do |chunk|
          fd.write(chunk)
          digest << chunk
        end
      end
    end
  end

  if digest.hexdigest != sha1
    fail "SHA1 does not match (expected '#{sha1}' but got '#{digest.hexdigest}')"
  end
ensure
  File.unlink(tmp) if File.exist?(tmp)
end
