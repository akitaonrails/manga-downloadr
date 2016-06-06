require "spec_helper"

describe MangaDownloadr::ImageDownloader do
  it "should download the image blob" do
    stub_request(:get, "http://i8.mangareader.net/naruto/662/naruto-4739563.jpg").
      to_return(status: 200, body: File.read("spec/fixtures/naruto-4739563.jpg"))

    image = MangaDownloadr::ImageDownloader.new("i8.mangareader.net").fetch("/naruto/662/naruto-4739563.jpg", "/tmp/naruto.jpg")
    expect(File.exists?("/tmp/naruto.jpg")).to eq(true)
    expect(File.size("/tmp/naruto.jpg")).to eq(File.size("spec/fixtures/naruto-4739563.jpg"))
  end
end
