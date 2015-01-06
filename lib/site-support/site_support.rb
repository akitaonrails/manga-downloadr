require 'uri'
require_relative 'site_manga_here'
require_relative 'site_manga_reader'

module SiteSupport
  class SiteSupportFactory
    @supported_sites = {:"www.mangahere.co"    => SiteSupportPlugin::MangaHere,
                        :"www.mangareader.net" => SiteSupportPlugin::MangaReader}

    def self.factory url
      @supported_sites[URI.parse(url).host.to_sym].new url
    end
  end
end