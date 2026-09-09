source 'https://rubygems.org'

# Specify your gem's dependencies in recourse.gemspec
gemspec

gem 'actioncable' # carries the dummy app's live index refreshes to the browser
gem 'activejob' # turbo-rails enqueues refresh broadcasts through it
gem 'irb' # REPL that bin/console starts
gem 'json', '< 3' # Active Support 8.1 hands JSON.parse a positional options hash json 3 refuses
gem 'minitest' # test framework
gem 'puma' # serves the dummy app when you run it in a browser
gem 'rake' # runs the default task: tests, then RuboCop
gem 'rubocop' # lints against the conventions in CLAUDE.md
gem 'simplecov' # fails the suite when coverage drops below 100%
gem 'sqlite3' # SQLite driver for the dummy app's database
gem 'turbo-rails' # live index refreshes: broadcasts_refreshes_to and turbo_stream_from
gem 'unicon', path: '../unicon' # until 3.6.0 ships: the expand and collapse arrows
