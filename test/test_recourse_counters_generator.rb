require 'test_helper'
require 'rails/generators/test_case'

Rails.application.load_generators
require 'generators/recourse/counters/counters_generator'

class TestRecourseCountersGenerator < Rails::Generators::TestCase
  tests Recourse::Generators::CountersGenerator
  destination File.expand_path('../tmp/counted', __dir__)

  # A bare line to grow a block, a block already open to join, and a shared line
  # to leave alone.
  ROUTES = <<~RUBY
    Rails.application.routes.draw do
      recourses :people, only: :index
      recourses :teams, only: :index do
        recourses :places, only: :index
      end
      recourses :zips, :memos, only: :index
    end
  RUBY

  def setup
    prepare_destination
    write 'app/models/memo.rb',
          "class Memo < ApplicationRecord\n  belongs_to :person, optional: true\nend\n"
    write 'app/models/person.rb', "class Person < ApplicationRecord\nend\n"
    write 'config/routes.rb', ROUTES
  end

  # `rails generate recourse:counters` has to reach it by that name, which is the
  # file's path and the class's namespace agreeing rather than anything declared.
  def test_it_answers_to_the_name_typed_in_a_terminal
    assert_equal Recourse::Generators::CountersGenerator,
                 Rails::Generators.find_by_namespace('recourse:counters')
  end

  # The three pieces of memos-count-on-people: the backfilled column, the option
  # that keeps it filled, and the has_many that reads it back — plus, on the same
  # person file, the far side of the optional places key, kept rather than
  # destroyed. Run twice, because idempotence is the point: everything is already
  # there the second time, so no second migration and no repeated line in a model.
  def test_it_writes_whichever_piece_of_a_count_is_missing_and_writes_it_once
    2.times { run_generator }

    assert_one_counter_migration
    assert_file 'app/models/memo.rb' do |memo|
      assert_equal 1, memo.scan('belongs_to :person, optional: true, counter_cache: true, ' \
                                'touch: true').count
    end
    assert_file 'app/models/person.rb' do |person|
      assert_equal 1, person.scan('has_many :memos, dependent: :nullify').count
      assert_equal 1, person.scan('has_many :places, dependent: :nullify').count
    end
    assert_file('config/routes.rb') { |routes| assert_nested_routes routes }
  end

  # Reading the USAGE is what `--help` does, and it has to say what comes after
  # the run: the migrations wait for `db:migrate`.
  def test_it_has_a_usage_to_print
    assert_match 'db:migrate', Recourse::Generators::CountersGenerator.desc
  end

private

  def assert_one_counter_migration
    assert_migration 'db/migrate/add_memos_count_to_people.rb',
                     /add_column :people, :memos_count, :integer, default: 0, null: false/
    assert_migration 'db/migrate/add_memos_count_to_people.rb', /update people set memos_count/
    assert_equal 1, Dir.glob("#{destination_root}/db/migrate/*_add_memos_count_to_people.rb").size
  end

  # A fresh `has_many` earns its children a nested route: the bare people line
  # became a block around the memos and places it just learned to read, and each
  # child is nested once however many times the generator runs.
  def assert_nested_routes(routes)
    nested = "  recourses :people, only: :index do\n    " \
             "recourses :memos\n    recourses :places\n  end"

    assert_includes routes, nested
    assert_equal 1, routes.scan("recourses :memos\n").count
    # A line naming more than one resource is left exactly as it was.
    assert_includes routes, "recourses :zips, :memos, only: :index\n"
  end

  def write(path, content)
    file = File.join destination_root, path
    FileUtils.mkdir_p File.dirname(file)
    File.write file, content
  end
end
