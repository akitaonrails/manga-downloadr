module MangaDownloadr
  class Workflow
    def self.run(config = Config.new)
      FileUtils.mkdir_p config.download_directory

      CM(config, Workflow)
        .fetch_chapters
        .fetch_pages(config)
        .fetch_images(config)
        .download_images(config)
        .optimize_images(config)
        .prepare_volumes(config)
        .unwrap

      puts "Done!"
    end

    def self.run_tests(config = Config.new)
      FileUtils.mkdir_p "/tmp/manga-downloadr-cache"

      CM(Workflow, config)
        .fetch_chapters
        .fetch_pages(config)
        .fetch_images(config)
        .unwrap

      puts "Done!"
    end

    def self.fetch_chapters(config)
      puts "Fetching chapters ..."
      chapters = Chapters.new(config.domain, config.root_uri, config.cache_http).fetch
      puts "Number of Chapters: #{chapters&.size}"
      chapters
    end

    def self.fetch_pages(chapters, config)
      puts "Fetching pages from all chapters ..."
      reactor = Concurrency.new(Pages, config)
      reactor.fetch(chapters) do |link, engine|
        engine&.fetch(link)
      end
    end

    def self.fetch_images(pages, config)
      puts "Feching the Image URLs from each Page ..."
      reactor = Concurrency.new(PageImage, config)
      reactor.fetch(pages) do |link, engine|
        [ engine&.fetch(link) ]
      end
    end

    def self.download_images(images, config)
      puts "Downloading each image ..."
      reactor = Concurrency.new(ImageDownloader, config, false)
      reactor.fetch(images) do |image, _|
        image_file = File.join(config.download_directory, image.filename)
        unless File.exists?(image_file)
          ImageDownloader.new(image.host).fetch(image.path, image_file)
        end
        [ image_file ]
      end
    end

    def self.optimize_images(downloads, config)
      puts "Running mogrify to convert all images down to Kindle supported size (600x800)"
      `mogrify -resize #{config.image_dimensions} #{config.download_directory}/*.jpg`
      downloads
    end

    def self.prepare_volumes(downloads, config)
      manga_name = config.download_directory.split("/")&.last
      index = 1
      volumes = []
      downloads.each_slice(config.pages_per_volume) do |batch|
        volume_directory = "#{config.download_directory}/#{manga_name}_#{index}"
        volume_file      = "#{volume_directory}.pdf"
        volumes << volume_file
        FileUtils.mkdir_p volume_directory

        puts "Moving images to #{volume_directory} ..."
        batch.each do |file|
          destination_file = file.split("/").last
          `mv #{file} #{volume_directory}/#{destination_file}`
        end

        puts "Generating #{volume_file} ..."
        `convert #{volume_directory}/*.jpg #{volume_file}`

        index += 1
      end
      volumes
    end
  end
end
