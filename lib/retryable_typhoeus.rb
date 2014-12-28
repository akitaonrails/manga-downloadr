# original source: https://gist.github.com/kunalmodi/2939288
module RetryableTyphoeus
  DEFAULT_RETRIES = 1

  module RequestExtension
    def original_on_complete=(proc)
      @original_on_complete = proc
    end

    def original_on_complete
      @original_on_complete
    end

    def retries=(retries)
      @retries = retries
    end

    def retries
      @retries ||= 0
    end
  end

  module HydraExtension
    def queue_with_retry(request, opts = {})
      request.retries = (opts[:retries] || RetryableTyphoeus::DEFAULT_RETRIES).to_i
      request.original_on_complete ||= request.on_complete
      request.on_complete do |response|
        if response.success? || response.request.retries <= 0
          request.original_on_complete.map do |callback|
            response.handled_response = callback.call(response)
          end
        else
          response.request.retries -= 1
          queue response.request
        end
      end
      queue request
    end
  end
end
