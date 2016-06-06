module MangaDownloadr
  class ImageDownloader < DownloadrClient
    def fetch(image_src, filename)
      File.delete(filename) if File.exists?(filename)
      response = @http_client.get(image_src, { "User-Agent": USER_AGENT })
      case response.code
      when "301"
        fetch(response.headers["Location"], filename)
      when "200"
        File.open(filename, "w") do |f|
          f.print response.body
        end
      end
    rescue Net::HTTPGatewayTimeOut, Net::HTTPRequestTimeOut
      sleep 1
      fetch(image_src, filename)
    end
  end
end
