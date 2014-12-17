require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'typhoeus'
require 'fileutils'
require 'rmagick'
require 'prawn'
require 'fastimage'
require 'open-uri'
require 'yaml'

module MangaDownloadr
  ImageData = Struct.new(:folder, :filename, :url)

  class Workflow
    attr_accessor :manga_root_url, :manga_root, :manga_root_folder, :manga_name, :hydra_concurrency
    attr_accessor :chapter_list, :chapter_pages, :chapter_images, :download_links, :chapter_pages_count
    attr_accessor :manga_title, :pages_per_volume, :page_size
    attr_accessor :processing_state

    def initialize(root_url, manga_name, options = {})
      self.manga_root_url    = root_url
      self.manga_root        = options[:manga_root] || "/vagrant/tmp/mangareader/"
      self.manga_root_folder = File.join(manga_root, manga_name)
      self.manga_name        = manga_name

      self.hydra_concurrency = options[:hydra_concurrency] || 100

      self.chapter_pages    = {}
      self.chapter_images   = {}

      self.pages_per_volume = options[:pages_per_volume] || 250
      self.page_size        = options[:page_size] || [600, 800]

      self.processing_state = []
    end

    def fetch_chapter_urls!
      doc = Nokogiri::HTML(open(manga_root_url))

      self.chapter_list = doc.css("#listing a").map { |l| l['href']}
      self.manga_title  = doc.css("#mangaproperties h1").first.text

      current_state :chapter_urls
    end

    def fetch_page_urls!
      hydra = Typhoeus::Hydra.new(max_concurrency: hydra_concurrency)
      chapter_list.each do |chapter_link|
        begin
          request = Typhoeus::Request.new "http://www.mangareader.net#{chapter_link}"
          request.on_complete do |response|
            chapter_doc = Nokogiri::HTML(response.body)
            pages = chapter_doc.css('#selectpage #pageMenu option')
            chapter_pages.merge!(chapter_link => pages.map { |p| p['value'] })
            print '.'
          end
          hydra.queue request
        rescue => e
          puts e
        end
      end
      hydra.run

      self.chapter_pages_count = chapter_pages.values.inject(0) { |total, list| total += list.size }
      current_state :page_urls
    end

    def fetch_image_urls!
      hydra = Typhoeus::Hydra.new(max_concurrency: hydra_concurrency)
      chapter_list.each do |chapter_key|
        chapter_pages[chapter_key].each do |page_link|
          begin
            request = Typhoeus::Request.new "http://www.mangareader.net#{page_link}"
            request.on_complete do |response|
              chapter_doc = Nokogiri::HTML(response.body)
              image       = chapter_doc.css('#img').first
              tokens      = image['alt'].match("^(.*?)\s\-\s(.*?)$")
              extension   = File.extname(URI.parse(image['src']).path)

              chapter_images.merge!(chapter_key => []) if chapter_images[chapter_key].nil?
              chapter_images[chapter_key] << ImageData.new( tokens[1], "#{tokens[2]}#{extension}", image['src'] )
              print '.'
            end
            hydra.queue request
          rescue => e
            puts e
          end
        end
      end
      hydra.run

      current_state :image_urls
    end

    def fetch_images!
      hydra = Typhoeus::Hydra.new(max_concurrency: hydra_concurrency)
      chapter_list.each_with_index do |chapter_key, chapter_index|
        chapter_images[chapter_key].each do |file|
          begin
            downloaded_filename = File.join(manga_root_folder, file.folder, file.filename)
            next if File.exists?(downloaded_filename) # effectively resumes the download list without re-downloading everything
            request = Typhoeus::Request.new file.url
            request.on_complete do |response|
              # download
              FileUtils.mkdir_p(File.join(manga_root_folder, file.folder))
              File.open(downloaded_filename, "wb+") { |f| f.write response.body }

              # resize
              image = Magick::Image.read( downloaded_filename ).first
              resized = image.resize_to_fit(600, 800)
              resized.write( downloaded_filename ) { self.quality = 50 }

              print '.'
              GC.start # to avoid a leak too big (ImageMagick is notorious for that, specially on resizes)
            end
            hydra.queue request
          rescue => e
            puts e
          end
        end
      end
      hydra.run

      current_state :images
    end

    def compile_ebooks!
      folders = Dir[manga_root_folder + "/*/"].sort_by { |element| ary = element.split(" ").last.to_i }
      self.download_links = folders.inject([]) do |list, folder|
        list += Dir[folder + "*.*"].sort_by { |element| ary = element.split(" ").last.to_i }
      end

      # concatenating PDF files (250 pages per volume)
      chapter_number = 0
      while !download_links.empty?
        chapter_number += 1
        pdf_file = File.join(manga_root_folder, "#{manga_title} #{chapter_number}.pdf")
        list = download_links.slice!(0..pages_per_volume)
        Prawn::Document.generate(pdf_file, page_size: page_size) do |pdf|
          list.each do |image_file|
            begin
              pdf.image image_file, position: :center, vposition: :center
            rescue => e
              puts "Error in #{image_file} - #{e}"
            end
          end
        end
        print '.'
      end

      current_state :ebooks
    end

    def state?(state)
      self.processing_state.include?(state)
    end

    private def current_state(state)
      self.processing_state << state
      MangaDownloadr::Workflow.serialize(self)
    end

    class << self
      def serialize(obj)
        File.open("/tmp/#{obj.manga_name}.yaml", 'w') {|f| f.write(YAML::dump(obj)) }
      end

      def create(root_url, manga_name, options = {})
        dump_file_name = "/tmp/#{manga_name}.yaml"
        return YAML::load(File.read(dump_file_name)) if File.exists?(dump_file_name)
        MangaGenerator.new(root_url, manga_name, options)
      end
    end
  end
end
