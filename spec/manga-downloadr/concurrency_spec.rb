require "spec_helper"

describe MangaDownloadr::Concurrency do
  it "should process a large queue of jobs in batches, concurrently and signal through a channel" do
    config     = MangaDownloadr::Config.new("foo.com", "/", "/tmp", 10, "", 10)
    reactor    = MangaDownloadr::Concurrency.new(MangaDownloadr::Pages, config, false)
    collection = ( 1..1_000 ).to_a
    results = reactor.fetch(collection) do |item, _|
      [item]
    end

    expect(results.size).to eq(1_000)
    expect(results.sort).to eq(collection)
  end
end
