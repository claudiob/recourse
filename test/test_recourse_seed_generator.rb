require 'test_helper'
require 'rails/generators/test_case'

Rails.application.load_generators
require 'generators/recourse/seed/seed_generator'

class TestRecourseSeedGenerator < Rails::Generators::TestCase
  tests Recourse::Generators::SeedGenerator
  destination File.expand_path('../tmp/generated_seeds', __dir__)

  def setup
    prepare_destination
    # One file is already there, to be left alone rather than offered for overwriting.
    FileUtils.mkdir_p File.join(destination_root, 'db/seeds')
    File.write File.join(destination_root, 'db/seeds/people.rb'), "# ours\n"
  end

  # `rails generate recourse:seed` has to reach it by that name, which is the file's
  # path and the class's namespace agreeing rather than anything declared.
  def test_it_answers_to_the_name_typed_in_a_terminal
    assert_equal Recourse::Generators::SeedGenerator,
                 Rails::Generators.find_by_namespace('recourse:seed')
  end

  # One file per model the routes declare — none for a resource with no model — each
  # opening with a bare row of what a row cannot save without. Values are drawn at
  # random while generating, to each column's own shape: 25 distinct strings of
  # random lengths inside their length validator's bounds and their column's SQL
  # limit, reading as words that reach past ASCII with no run longer than a word may
  # be, and a reference reading a random row of its table rather than forever the
  # first.
  def test_it_seeds_twenty_five_rows_for_every_recoursed_model
    run_generator

    assert_file 'db/seeds/zips.rb' do |zips|
      assert_equal 25, zips.scan(/^  \{ code: '[^']+', fips: '[^']+', city: '[^']+' \},$/).uniq.size
      assert_match(/[^\x00-\x7F]/, zips)
      assert_match(/rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid/, zips)
    end
    assert_file('db/seeds/memos.rb') { |memos| assert_wrapped_contents memos }
    assert_file 'db/seeds/places.rb', /zip: ZIP\.offset\(\d+\)\.first/
    assert_shaped_strings
    assert_skipped_files
  end

private

  # Neither file is written: one was already there and is the host's to keep, and
  # the other names a resource with no model behind it.
  def assert_skipped_files
    assert_file 'db/seeds/people.rb', "# ours\n"
    assert_no_file 'db/seeds/placeholders.rb'
  end

  # Every shape fits its own gates: a ZIP's code and FIPS are their columns' five
  # characters, a phone is a phone, and a string named like an id — the app's
  # `uid` — is digits and nothing else.
  def assert_shaped_strings
    assert_file 'db/seeds/zips.rb', /code: '[^']{5}', fips: '[^']{5}'/
    assert_file 'db/seeds/places.rb', /phone: '555234\d{4}'/
    assert_file 'db/seeds/teams.rb', /uid: '\d+'/
  end

  # The bare row opens the file, and every body reads as words: nothing runs past
  # the fifteen unbroken characters a single word may be.
  def assert_wrapped_contents(memos)
    assert_match(/^  \{ body: '[^']+' \},$/, memos)
    memos.scan(/body: '([^']+)'/).flatten.each { |body| refute_match(/[^ ]{16,}/, body) }
  end
end
