module MangaDownloadr
  class Concurrency
    def initialize(engine_klass = nil, config = Config.new, turn_on_engine = true)
      @engine_klass = engine_klass
      @config = config
      @turn_on_engine = turn_on_engine
    end

    def fetch(collection, &block)
      results = []
      collection&.each_slice(@config.download_batch_size) do |batch|
        mutex   = Mutex.new
        threads = batch.map do |item|
          Thread.new {
            engine  = @turn_on_engine ? @engine_klass.new(@config.domain) : nil
            Thread.current["results"] = block.call(item, engine)&.flatten
            mutex.synchronize do
              results += Thread.current["results"]
            end
          }
        end
        threads.each(&:join)
        puts "Processed so far: #{results&.size}"
      end
      results
    end
  end
end
