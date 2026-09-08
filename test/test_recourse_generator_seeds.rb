require 'test_helper'
require 'rails/generators/test_case'

Rails.application.load_generators
require 'generators/recourse/recourse_generator'

# The seed file `rails generate recourse` writes, which is the file
# `recourse:seed` writes: one engine, reading the attributes just parsed rather
# than a table that does not exist yet.
class TestRecourseGeneratorSeeds < Rails::Generators::TestCase
  tests Recourse::Generators::RecourseGenerator
  destination File.expand_path('../tmp/generated_rows', __dir__)

  def setup
    prepare_destination
    FileUtils.mkdir_p "#{destination_root}/config"
    File.write "#{destination_root}/config/routes.rb", "Rails.application.routes.draw do\nend\n"
  end

  # The first row carries only what a row cannot save without, the last fills
  # everything, and the rest mix which optional columns are filled.
  def test_it_seeds_a_spread_of_rows_and_teaches_db_seeds_to_load_them
    run_generator %w[widget name:string! nickname:string{40} code:string:uniq
                     market:references quantity:integer]

    assert_file 'db/seeds/widgets.rb' do |widgets|
      rows = widgets.scan(/^  \{ (.+) \},$/).flatten.map { |row| row.scan(/(\w+):/).flatten }

      assert_equal 25, rows.size
      assert_equal %w[name market], rows.first
      assert_equal %w[name nickname code market quantity], rows.last
    end
    assert_file 'db/seeds.rb', %r{Dir\[Rails\.root\.join\('db/seeds/\*\.rb'\)\]}
  end

  # A foreign key is required however bare a row is meant to be — `belongs_to` says
  # so — and a column named for an address is given one.
  def test_a_bare_row_carries_the_keys_it_cannot_save_without
    run_generator %w[author name:string! email:string!]
    run_generator %w[post title content:text author:references published_on:date]

    assert_file 'db/seeds/authors.rb', /^  \{ name: '[^']+', email: '\w+@example\.com' \},$/
    assert_file 'db/seeds/posts.rb', /^  \{ author: Author\.first \},$/,
                /content: '[^']+', author: Author\.first, published_on: Date\.current/
  end
end
