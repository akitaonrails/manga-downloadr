module MangaDownloadr
  class Pages < DownloadrClient
    def fetch(chapter_link)
      get chapter_link do |html|
        nodes = html.xpath("//div[@id='selectpage']//select[@id='pageMenu']//option")
        nodes.map { |node| [chapter_link, node.children.to_s].join("/") }
      end
    end
  end
end
