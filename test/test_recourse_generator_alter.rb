require 'test_helper'
require 'rails/generators/test_case'

Rails.application.load_generators
require 'generators/recourse/recourse_generator'

# A run over a resource the routes already draw adds to the table it has, rather
# than refusing the name it finds taken.
class TestRecourseGeneratorAlter < Rails::Generators::TestCase
  tests Recourse::Generators::RecourseGenerator
  destination File.expand_path('../tmp/altered', __dir__)

  def setup
    prepare_destination
    FileUtils.mkdir_p "#{destination_root}/config"
    File.write "#{destination_root}/config/routes.rb", "Rails.application.routes.draw do\nend\n"
  end

  # Everything a `references` earns when the table is made, earned again when it is
  # added to: the column, the count on the parent, and both sides of the assocation.
  def test_a_second_run_adds_to_the_table_the_first_one_made
    add_an_author_to_comments

    assert_migration 'db/migrate/add_author_and_title_to_comments.rb',
                     /add_reference :comments, :author, null: false, foreign_key: true/,
                     /add_column :authors, :comments_count, :integer, default: 0, null: false/,
                     /add_column :comments, :title, :string, limit: 80, null: false/
    assert_file 'app/models/comment.rb',
                /belongs_to :author, counter_cache: true, touch: true/,
                /validates :title, presence: true, length: \{ maximum: 80 \}/
    assert_file 'app/models/author.rb', /has_many :comments, dependent: :destroy/
    assert_equal 1, routes.scan('recourses :comments').size
  end

  # Nothing to add is nothing to write — and no migration named after no column.
  def test_a_run_that_adds_no_column_writes_no_migration
    run_generator %w[comment body:text]
    written = migrations

    run_generator %w[comment]

    assert_equal written, migrations
  end

private

  def add_an_author_to_comments
    run_generator %w[author name:string!]
    run_generator %w[comment body:text]
    run_generator %w[comment author:references title:string{80}!]
  end

  def routes
    File.read File.join(destination_root, 'config/routes.rb')
  end

  def migrations
    Dir[File.join(destination_root, 'db/migrate/*.rb')]
  end
end
