Rails.application.configure do
  config.eager_load = false

  # Discard log output, and keep the cache in memory: a test run should not leave
  # files behind. Caching stays on, so the suite exercises what a host would get.
  config.logger = ActiveSupport::Logger.new IO::NULL
  config.cache_store = :memory_store

  # Let failures raise into the test instead of becoming a 500 page.
  config.action_dispatch.show_exceptions = :none

  # A test posts straight to create, without fetching a form for its token first.
  config.action_controller.allow_forgery_protection = false

  # The default `:async` runs jobs on background threads; a test reads them queued.
  config.active_job.queue_adapter = :test
end
