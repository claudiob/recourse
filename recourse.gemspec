require_relative 'lib/recourse/version'

Gem::Specification.new do |spec|
  spec.name = 'recourse'
  spec.version = Recourse::VERSION
  spec.authors = ['claudiob']
  spec.email = ['claudiob@users.noreply.github.com']

  spec.summary = 'A routes.rb DSL that mounts ready-made resource screens.'
  spec.description = 'Recourse adds a `recourses` method to config/routes.rb. ' \
                     'One line draws the routes, controllers and views needed to ' \
                     'browse and edit a resource, with no files added to the host ' \
                     'app. Any controller, view or partial can be overridden by ' \
                     'defining it in the app.'
  spec.homepage = 'https://github.com/claudiob/recourse'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/recourse'

  # Whatever git tracks, less what only a contributor needs, so nothing untracked leaks in.
  gemspec = File.basename __FILE__
  contributor_only = %w[bin/ test/ .github/ .gitignore .rubocop.yml
                        CLAUDE.md Gemfile Rakefile ROADMAP.md STYLE.md]
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*contributor_only)
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 8.1' # the routing DSL and controllers we extend
  spec.add_dependency 'activerecord', '>= 8.1' # reads the host app's resources
  spec.add_dependency 'pagy', '>= 43.6' # paginates the index pages
  spec.add_dependency 'railties', '>= 8.1' # Rails::Engine, which mounts the screens
  spec.add_dependency 'ransack', '>= 4.4' # sorts, searches and filters the index pages
  spec.add_dependency 'turbo-rails' # without it a delete asks nothing before deleting
  spec.add_dependency 'unicon', '>= 3.2' # names every icon drawn, in Bootstrap Icons
end
