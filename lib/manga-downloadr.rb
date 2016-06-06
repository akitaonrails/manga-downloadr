require "rubygems"
require "bundler/setup"

require "chainable_methods"
require "nokogiri"
require "fileutils"
require "net/http"
require "open-uri"

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib")

require "manga-downloadr/records.rb"
require "manga-downloadr/downloadr_client.rb"
require "manga-downloadr/concurrency.rb"
require "manga-downloadr/chapters.rb"
require "manga-downloadr/pages.rb"
require "manga-downloadr/page_image.rb"
require "manga-downloadr/image_downloader.rb"
require "manga-downloadr/workflow.rb"
