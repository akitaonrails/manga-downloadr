module SiteSupportPlugin
  class MangaHere
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
end