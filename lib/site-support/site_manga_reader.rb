module SiteSupportPlugin
  class MangaReader
    def initialize url
      @url = url
    end

    def manga_title
      "#mangaproperties h1"
    end

    def chapter_list
      "#listing a"
    end

    def chapter_list_parse url
      URI.parse(@url).host + url
    end

    def page_list
      '#selectpage #pageMenu option'
    end

    def page_list_parse url
      URI.parse(@url).host + url
    end

    def image
      '#img'
    end

    def image_alt text
      text.match("^(.*?)\s\-\s(.*?)$")
    end
  end
end