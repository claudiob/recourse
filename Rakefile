require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

require 'rubocop/rake_task'

RuboCop::RakeTask.new

# Ceiling for every code file, blank and comment lines included.
MAX_FILE_LINES = 100

# Prose and markup are exempt: docs and views of any length. So is artwork — a
# drawing has no lines to count, and a PNG rendered from one is only as many as
# its bytes happen to hold a newline.
EXEMPT_EXTENSIONS = %w[.erb .html .ico .md .png .svg .txt].freeze

# Two directories are exempt: a backfill is as long as the data it carries, and
# upstream's formatting is not ours to fix.
EXEMPT_DIRECTORIES = %w[db/migrate/ vendor/].freeze

desc "Fail if any code file is longer than #{MAX_FILE_LINES} lines"
task :file_length do
  files = `git ls-files -z`.split "\x0"
  code = files.reject do |file|
    EXEMPT_EXTENSIONS.include?(File.extname(file)) ||
      EXEMPT_DIRECTORIES.any? { |directory| file.include? directory }
  end
  too_long = code.select { |file| File.readlines(file).size > MAX_FILE_LINES }

  abort "Longer than #{MAX_FILE_LINES} lines: #{too_long.join ', '}" if too_long.any?
end

task default: %i[test rubocop file_length]
