module MangaDownloadr
  Image  = Struct.new *%i[host path filename]
  Config = Struct.new *%i[domain root_uri download_directory download_batch_size image_dimensions pages_per_volume cache_http]

  HTTPResponse = Struct.new *%i[code body]

  USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/45.0.2454.101 Chrome/45.0.2454.101 Safari/537.36"
end
