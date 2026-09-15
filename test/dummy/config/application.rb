require_relative 'boot'

require 'action_cable/engine'
require 'action_controller/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'

# After the frameworks: it only extends Active Record when Active Job is loaded.
require 'turbo-rails'

require 'recourse'

module Dummy
  # Stand-in for a host app, so tests exercise the gem through a booting Rails.
  class Application < Rails::Application
    config.root = File.expand_path '..', __dir__
    config.load_defaults 8.1
    config.secret_key_base = 'dummy_secret_key_base'
    config.time_zone = 'Eastern Time (US & Canada)'

    # A file has to live somewhere for a table of them to be worth drawing.
    config.active_storage.service = :test

    # No schema.rb: loading one stamps the backfills as done and skips the data.
    config.active_record.dump_schema_after_migration = false

    # Action View logs a line per partial, which buries the request itself.
    config.action_view.logger = nil

    # The cable is not what a log is about either. The middleware is the one
    # `silence_healthcheck_path` uses, aimed at `/cable`, so no `Started GET`
    # line; the nil cable logger is what swallows `Successfully upgraded` and
    # every `Turbo::StreamsChannel is streaming` line.
    config.middleware.insert_before Rails::Rack::Logger, Rails::Rack::SilenceRequest, path: '/cable'
    config.action_cable.logger = ActiveSupport::Logger.new nil

    # Bootstrap wants `is-invalid` on the control and the message beside it, which
    # Rails' default `field_with_errors` wrapper gives neither. Labels pass through.
    config.action_view.field_error_proc = proc do |html_tag, instance|
      next html_tag unless html_tag.include? 'form-control'

      described = "#{html_tag[/id="([^"]*)"/, 1]}_error"
      # A SafeBuffer escapes whatever is inserted, so the attribute is built safe.
      aria = safe_join [' ', tag.attributes('aria-describedby': described)]
      html_tag.insert html_tag.index('form-control'), 'is-invalid '
      html_tag.insert html_tag.index(' '), aria
      messages = instance.error_message.to_sentence.upcase_first

      safe_join [html_tag, tag.small(messages, class: 'invalid-feedback', id: described)]
    end

    # Throwaway keys, so a model can encrypt an attribute and prove it is hidden.
    config.active_record.encryption.primary_key = 'dummy_primary_key_for_the_dummy_app'
    config.active_record.encryption.deterministic_key = 'dummy_deterministic_key_for_dummy'
    config.active_record.encryption.key_derivation_salt = 'dummy_key_derivation_salt_for_it'
    config.active_record.encryption.support_unencrypted_data = true
  end
end
