require "spec_helper"

describe MangaDownloadr::Chapters do
  it "should fetch all of the manga main chapter links" do
    stub_request(:get, "www.mangareader.net/naruto").
      to_return(status: 200, body: File.read("spec/fixtures/naruto.html"))

    chapters = MangaDownloadr::Chapters.new("www.mangareader.net", "/naruto", false).fetch

    expect(chapters&.size).to eq(700)
    expect(chapters&.first).to eq("/naruto/1")
  end
end
