require 'uri'

module SiteSuport
  class SiteMangaReader
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

  class SiteMangaHere
    def initialize url
      @url = url
    end

    def manga_title
      "h1.title"
    end

    def chapter_list
      ".detail_list ul a"
    end

    def chapter_list_parse url
      url
    end

    def page_list
      ".readpage_top .go_page .right select option"
    end

    def page_list_parse url
      url
    end

    def image
      "\#image"
    end

    def image_alt text
      text.match(/^(.*\s\d+.*\d*?)\s(Page\s\d+?)$/)
    end
  end

  class SiteSuportFactory
    @suported_sites = {:"www.mangareader.net" => SiteMangaReader,
                       :"www.mangahere.co" => SiteMangaHere}

    def self.factory url
      @suported_sites[URI.parse(url).host.to_sym].new url
    end
  end
end