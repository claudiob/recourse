source 'https://rubygems.org'

# Specify your gem's dependencies in recourse.gemspec

# The design layer, worked on beside this gem rather than through a release.
gem 'bh', path: '../bh' # the layer these pages are drawn on, worked on beside them
gemspec

gem 'actioncable' # carries the dummy app's live index refreshes to the browser
gem 'activejob' # turbo-rails enqueues refresh broadcasts through it
gem 'activestorage' # the dummy attaches a file, so a table of attachments has one to draw
gem 'image_processing' # the dummy makes the pictures a table of files shows
gem 'irb' # REPL that bin/console starts
gem 'json', '< 3' # Active Support 8.1 hands JSON.parse a positional options hash json 3 refuses
gem 'minitest' # test framework
gem 'puma' # serves the dummy app when you run it in a browser
gem 'rake' # runs the default task: tests, then RuboCop
gem 'rubocop' # lints against the conventions in CLAUDE.md
gem 'ruby-vips' # the processor image_processing scales a picture with
gem 'simplecov' # fails the suite when coverage drops below 100%
gem 'sqlite3' # SQLite driver for the dummy app's database
gem 'turbo-rails' # live index refreshes: broadcasts_refreshes_to and turbo_stream_from
