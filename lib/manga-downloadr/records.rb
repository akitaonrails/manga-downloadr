module MangaDownloadr
  Image  = Struct.new *%i[host path filename]
  Config = Struct.new *%i[domain root_uri download_directory download_batch_size image_dimensions pages_per_volume]
end
