Rails.application.configure do
  config.eager_load = false
  config.enable_reloading = true
  config.consider_all_requests_local = true
  # No `:page_load`: this app's migrations are run by the suite against its own
  # database, so browsing the development one with a migration outstanding is
  # ordinary here rather than a mistake to stop on. `rake` still runs them all.
  config.active_record.migration_error = false
end
