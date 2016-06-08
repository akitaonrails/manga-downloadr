require "spec_helper"

describe MangaDownloadr::PageImage do
  it "should fetch the image metadata of the page" do
    stub_request(:get, "www.mangareader.net/naruto/662/2").
      to_return(status: 200, body: File.read("spec/fixtures/naruto_662_2.html"))

    image = MangaDownloadr::PageImage.new("www.mangareader.net", false).fetch("/naruto/662/2")

    expect(image&.host).to eq("i8.mangareader.net")
    expect(image&.path).to eq("/naruto/662/naruto-4739563.jpg")
    expect(image&.filename).to eq("Naruto-Chap-00662-Pg-00002.jpg")
  end
end
