require 'spec_helper'

describe MangaDownloadr::Workflow do
  it "should require parameters on initialize" do
    expect { MangaDownloadr::Workflow.new }.to raise_error(ArgumentError)
    expect { MangaDownloadr::Workflow.new("a") }.to raise_error(ArgumentError)
    expect { MangaDownloadr::Workflow.new("a", "b") }.to raise_error(ArgumentError)
    expect { MangaDownloadr::Workflow.new("a", "b", "c") }.not_to raise_error
  end

  context "valid Workflow object" do
    let(:root_url) { "http://www.mangareader.net/93/naruto.html"}
    let(:workflow) { MangaDownloadr::Workflow.new(root_url, "naruto", "/tmp") }
    let(:sample_chapter_url) { "/93-1-1/naruto/chapter-1.html" }
    let(:sample_page_url) { "/93-1-53/naruto/chapter-1.html" }
    let(:sample_page_image) { MangaDownloadr::ImageData.new("Naruto 1", "Page 53.jpg",
                                                            "http://i1.mangareader.net/naruto/1/naruto-1564825.jpg")}
    let(:sample_downloaded_image) { "/tmp/naruto/Naruto\ 1/Page\ 53.jpg" }
    let(:sample_compiled_pdf) { "/tmp/naruto/Naruto Manga 1.pdf" }

    before do
      stub_request(:get, root_url).
        to_return(body: File.read("spec/fixtures/naruto.html"))
      stub_request(:get, "http://www.mangareader.net#{sample_chapter_url}").
        to_return(body: File.read("spec/fixtures/chapter-1.html"))
      stub_request(:get, "http://www.mangareader.net#{sample_page_url}").
        to_return(body: File.read("spec/fixtures/page-1-53.html"))
      stub_request(:get, "http://i1.mangareader.net/naruto/1/naruto-1564825.jpg").
        to_return(body: File.read("spec/fixtures/naruto-1564825.jpg"))

      workflow.manga_title = "Naruto Manga"
      workflow.chapter_list   = [ sample_chapter_url ]
      workflow.chapter_pages  = { sample_chapter_url => [ sample_page_url ]}
      workflow.chapter_images = { sample_chapter_url => [ sample_page_image ] }
    end

    after do
      FileUtils.rm_rf(sample_downloaded_image) if File.exists?(sample_downloaded_image)
      FileUtils.rm_rf(sample_compiled_pdf) if File.exists?(sample_compiled_pdf)
    end

    it "should fetch chapter urls" do
      workflow.manga_title = nil
      workflow.chapter_list = {}
      workflow.fetch_chapter_urls!

      expect(workflow.manga_title).to eq("Naruto Manga")
      expect(workflow.chapter_list.size).to eq(700)
      expect(workflow.chapter_list.first).to eq(sample_chapter_url)
    end

    it "should fetch page urls from each chapter in the list" do
      workflow.chapter_pages = {}
      workflow.fetch_page_urls!

      expect(workflow.chapter_pages.size).to eq(1)
      expect(workflow.chapter_pages[sample_chapter_url].size).to eq(53)
      expect(workflow.chapter_pages[sample_chapter_url].last).to eq(sample_page_url)
    end

    it "should fetch the image urls from the pages of the sample chapter" do
      workflow.chapter_images = {}
      workflow.fetch_image_urls!

      expect(workflow.chapter_images.size).to eq(1)
      expect(workflow.chapter_images[sample_chapter_url].size).to eq(1)
      expect(workflow.chapter_images[sample_chapter_url].first).to eq(sample_page_image)
    end

    it "should download the image from the specific page" do
      workflow.fetch_images!

      expect(File.exists?(sample_downloaded_image)).to eq(true)
    end

    it "should generate a PDF ebook using the sample image" do
      FileUtils.cp("spec/fixtures/naruto-1564825.jpg", sample_downloaded_image)
      workflow.compile_ebooks!

      expect(File.exists?(sample_compiled_pdf)).to eq(true)
    end
  end
end
