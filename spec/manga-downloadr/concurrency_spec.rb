require "spec_helper"
require "benchmark"

describe MangaDownloadr::Concurrency do
  let(:config) { MangaDownloadr::Config.new("www.mangareader.net", "/", "/tmp", 10, "", 10) }

  it "should process a large queue of jobs in batches, concurrently and signal through a channel" do
    reactor = MangaDownloadr::Concurrency.new(MangaDownloadr::Pages, config, false)
    collection = ( 1..1_000 ).to_a
    results = reactor.fetch(collection) do |item, _|
      [item]
    end

    expect(results.size).to eq(1_000)
    expect(results.sort).to eq(collection)
  end

  it "should check that the fetch implementation runs in less time than the sequential version" do
    reactor = MangaDownloadr::Concurrency.new(MangaDownloadr::Pages, config, true)
    collection = ["/onepunch-man/96"] * 10

    WebMock.allow_net_connect!
    begin
      concurrent_measurement = Benchmark.measure {
        results = reactor.fetch(collection) { |link, engine| engine&.fetch(link) }
      }

      sequential_measurement = Benchmark.measure {
        results = reactor.send(:fetch_sequential, collection) { |link, engine| engine&.fetch(link) }
      }

      /\((.*?)\)$/.match(concurrent_measurement.to_s) do |cm|
        /\((.*?)\)/.match(sequential_measurement.to_s) do |sm|
          # expected for the concurrent version to be close to 10 times faster than sequential
          expect(sm[1].to_f).to be > ( cm[1].to_f * 9 )
        end
      end
    ensure
      WebMock.disable_net_connect!
    end
  end
end
