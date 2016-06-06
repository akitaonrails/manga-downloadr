module MangaDownloadr
  class DownloadrClient
    def initialize(domain)
      @domain = domain
      @http_client = Net::HTTP.new(@domain)
    end

    def get(uri, &block)
      response = @http_client.get(uri)
      case response.code
      when "301"
        get response.headers["Location"], &block
      when "200"
        parsed = Nokogiri::HTML(response.body)
        block.call(parsed)
      end
    rescue Net::HTTPGatewayTimeOut, Net::HTTPRequestTimeOut
      # TODO: naive infinite retry, it will loop infinitely if the link really doesn't exist
      # so should have a way to control the amount of retries per link
      sleep 1
      get(uri, &block)
    end
  end
end
