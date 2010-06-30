module Dragonfly
  class Endpoint

    class EmptyJob < StandardError; end

    include BelongsToApp

    def initialize(job)
      @job = job
      @app = job.app
    end

    attr_reader :job

    def call(env=nil)
      raise EmptyJob, "Job contains no steps" if job.empty?
      temp_object = job.apply
      [200, {
        "Content-Type" => mime_type,
        "Content-Length" => temp_object.size.to_s,
        "Cache-Control" => "public, max-age=#{app.cache_duration}"
        }, temp_object]
    rescue DataStorage::DataNotFound => e
      [404, {"Content-Type" => 'text/plain'}, [e.message]]
    end

    private
    
    def mime_type
      job.mime_type || job.analyse(:mime_type) || app.fallback_mime_type
    end

  end
end
