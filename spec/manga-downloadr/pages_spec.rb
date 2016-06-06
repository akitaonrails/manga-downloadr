require "spec_helper"

describe MangaDownloadr::Pages do
  it "should fetch all of the page links of a chapter" do
    stub_request(:get, "www.mangareader.net/naruto/1").
      to_return(status: 200, body: File.read("spec/fixtures/naruto_1.html"))

    pages = MangaDownloadr::Pages.new("www.mangareader.net").fetch("/naruto/1")

    expect(pages&.size).to eq(53)
    expect(pages&.first).to eq("/naruto/1/1")
    expect(pages&.last).to eq("/naruto/1/53")
  end
end
