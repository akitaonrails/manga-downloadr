require "thread/pool"

module MangaDownloadr
  class Concurrency
    def initialize(engine_klass = nil, config = Config.new, turn_on_engine = true)
      @engine_klass   = engine_klass
      @config         = config
      @turn_on_engine = turn_on_engine
    end

    def fetch(collection, &block)
      pool    = Thread.pool(@config.download_batch_size)
      mutex   = Mutex.new
      results = []

      collection.each do |item|
        pool.process {
          engine  = @turn_on_engine ? @engine_klass.new(@config.domain, @config.cache_http) : nil
          reply = block.call(item, engine)&.flatten
          mutex.synchronize do
            results += ( reply || [] )
          end
        }
      end
      pool.shutdown

      results
    end

    private

    # this method is the same as the above but sequential, without Threads
    # it's not to be used in the application, just to be used as a baseline for benchmark
    def fetch_sequential(collection, &block)
      results = []
      engine  = @turn_on_engine ? @engine_klass.new(@config.domain, @config.cache_http) : nil
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
