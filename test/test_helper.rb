require 'simplecov'

# Started before anything else is required, or the gem's own files load untracked.
SimpleCov.start do
  skip '/test/'
  minimum_coverage 100
end

ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'recourse'
require_relative 'dummy/config/environment'

require 'minitest/autorun'

# SQLite creates the database file on first connection, so migrating is all the
# first run needs, and it is a no-op afterwards.
ActiveRecord::Migration.suppress_messages do
  ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate')).migrate
end

# A model a backfill touches caches its columns mid-history, and a later migration
# that reshapes the same table leaves the class describing columns that are gone.
# Reset them once the last migration has spoken; a first run is the only one this
# changes, since afterwards migrating alters nothing.
ApplicationRecord.descendants.each(&:reset_column_information)

# Routes load lazily, and `recourses` defines controllers as it draws them, so a
# test that never issues a request would otherwise not see them.
Rails.application.reload_routes_unless_loaded

# turbo-rails swaps this in through an on_load hook only ActiveSupport::TestCase
# fires, and this suite runs on Minitest::Test: without it every refresh broadcast
# waits half a second on a background thread the test never joins.
Turbo::ThreadDebouncer.debouncer_class = Turbo::ImmediateDebouncer
