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
              results += ( Thread.current["results"] || [] )
            end
          }
        end
        threads.each(&:join)
        puts "Processed so far: #{results&.size}"
      end
      results
    end

    private

    # this method is the same as the above but sequential, without Threads
    # it's not to be used in the application, just to be used as a baseline for benchmark
    def fetch_sequential(collection, &block)
      results = []
      engine  = @turn_on_engine ? @engine_klass.new(@config.domain) : nil
      collection&.each_slice(@config.download_batch_size) do |batch|
        batch.each do |item|
          batch_results = block.call(item, engine)&.flatten
          results += ( batch_results || [])
        end
      end
      results
    end
  end
end
