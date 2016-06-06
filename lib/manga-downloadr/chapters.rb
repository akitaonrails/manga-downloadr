module MangaDownloadr
  class Chapters < DownloadrClient
    def initialize(domain, root_uri)
      @root_uri = root_uri
      super(domain)
    end

    def fetch
      get @root_uri do |html|
        nodes = html.css("#listing a")
        nodes.map { |node| node["href"] }
      end
    end
  end
end
