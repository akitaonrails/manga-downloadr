require File.expand_path("../lib/your_gem/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'manga-downloadr'
  gem.version = MangaDownloadr::VERSION
  gem.date    = Date.today.to_s

  gem.summary = "downloads and compile to a Kindle optimized manga in PDF"
  gem.description = "downloads any manga from MangaReader.net"

  gem.authors  = ['AkitaOnRails']
  gem.email    = 'boss@akitaonrails.com'
  gem.homepage = 'http://github.com/akitaonrails/manga-downloadr'

  gem.add_dependency('nokogiri')
  gem.add_dependency('typhoeus')
  gem.add_dependency('rmagick')
  gem.add_dependency('prawn')
  gem.add_dependency('fastimage')

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', '{bin,lib}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end
