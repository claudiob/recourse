require_relative 'lib/recourse/version'

Gem::Specification.new do |spec|
  spec.name        = 'recourse'
  spec.version     = Recourse::VERSION
  spec.authors     = [ 'Claudio Baccigalupo' ]
  spec.email       = [ 'claudiob@users.noreply.github.com' ]
  spec.homepage    = 'https://github.com/claudiob/recourse'
  spec.summary     = 'Rails admin tool'
  spec.description = 'Turns resources into recourses'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/claudiob/recourse/'
  spec.metadata['changelog_uri']   = 'https://github.com/claudiob/recourse/blob/master/CHANGELOG.md'
  spec.required_ruby_version       = '>= 3'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails'
  spec.add_dependency 'pagy'
  spec.add_dependency 'ransack'
  spec.add_development_dependency 'minitest', '< 6'
  spec.add_development_dependency 'simplecov'
end
