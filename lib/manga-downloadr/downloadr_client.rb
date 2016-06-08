require "digest"

module MangaDownloadr
  class DownloadrClient
    def initialize(domain, cache_http)
      @domain = domain
      @cache_http = cache_http
      @http_client = Net::HTTP.new(@domain)
    end

    def get(uri, &block)
      cache_path = "/tmp/manga-downloadr-cache/#{cache_filename(uri)}"
      response = if @cache_http && File.exists?(cache_path)
        body = File.read(cache_path)
        MangaDownloadr::HTTPResponse.new("200", body)
      else
        @http_client.get(uri, { "User-Agent": USER_AGENT })
      end

      case response.code
      when "301"
        get response.headers["Location"], &block
      when "200"
        if @cache_http && !File.exists?(cache_path)
          File.open(cache_path, "w") do |f|
            f.write response.body
          end
        end
        parsed = Nokogiri::HTML(response.body)
        block.call(parsed)
      end
    rescue Net::HTTPGatewayTimeOut, Net::HTTPRequestTimeOut
      # TODO: naive infinite retry, it will loop infinitely if the link really doesn't exist
      # so should have a way to control the amount of retries per link
      sleep 1
      get(uri, &block)
    end

    private def cache_filename(uri)
      Digest::MD5.hexdigest(uri)
    end
  end
end
