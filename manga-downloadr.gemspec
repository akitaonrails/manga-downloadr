require File.expand_path("../lib/manga-downloadr/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = "manga-downloadr"
  gem.version = MangaDownloadr::VERSION
  gem.date    = Date.today.to_s
  gem.licenses = ["MIT"]

  gem.summary = "downloads and compile to a Kindle optimized manga in PDF"
  gem.description = "downloads any manga from MangaReader.net"

  gem.authors  = ["AkitaOnRails"]
  gem.email    = "boss@akitaonrails.com"
  gem.homepage = "http://github.com/akitaonrails/manga-downloadr"

  gem.add_dependency("nokogiri", "~> 1.6")
  gem.add_dependency("chainable_methods", "~> 0.1.2")

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "pry"

  # ensure the gem is built out of versioned files
  gem.files = Dir["Rakefile", "{bin,lib}/**/*", "README*", "LICENSE*"] & `git ls-files -z`.split("\0")

  gem.bindir = "bin"
  gem.executables << "manga-downloadr"
end
