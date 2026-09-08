require 'test_helper'
require 'integration_case'

# A foreign key whose label is typed rather than picked, and what becomes of the words
# somebody typed into it.
class TestRecoursesReferences < IntegrationCase
  def teardown
    Reading.where(depth: 4_242).destroy_all
  end

  # What a key reads as on a table, which is the label of the record it points at --
  # led to that record's own page where the routes drew one that can be linked to, and
  # left as words where they did not. A person has such a page here; a ZIP and a team
  # are drawn under a parent and have none. `reverse.to_h` keeps the first row's cells,
  # since every row of the table carries the same three names.
  def test_a_key_leads_to_the_record_it_names_where_that_record_has_a_page
    visit '/places'
    drawn = body.scan(%r{data-cell="([^"]+)"[^>]*>(.*?)</td>}m).reverse.to_h

    assert_match %r{\A<a [^>]*href="/people/\d+">\w+</a>\z}, drawn['Person'].strip
    assert_equal 'Blue Crew', drawn['Team'].strip
    refute_includes drawn['ZIP'], '<a'
  end

  # The ordinary case: the words name one row, and the key points at it.
  def test_a_label_naming_one_row_is_the_row_it_names
    sensor = Sensor.find_by! name: 'Weir'

    @session.post '/readings', params: { reading: { depth: 4_242, sensor_id: 'Weir' } }

    assert_equal 303, @session.response.status
    assert_equal sensor, Reading.find_by!(depth: 4_242).sensor
  end

  # And the one this is about. Two sensors answer to `North gate`, so the words name a
  # sensor without saying which — and the first of the two is not an answer, only the
  # one the database happened to return. Nothing is written, and the field says why.
  def test_a_label_naming_two_rows_is_refused_rather_than_guessed_at
    named = Sensor.where(name: 'North gate').count

    @session.post '/readings',
                  params: { reading: { depth: 4_242, sensor_id: 'North gate' } }

    assert_operator named, :>, 1
    assert_equal 422, @session.response.status
    assert_nil Reading.find_by(depth: 4_242)
    assert_includes body, 'Matches more than one record, so it does not say which'
    assert_includes body, 'North gate'
  end

  # A label naming nothing is the case that already worked: the key is left empty, and
  # what becomes of the record is the association's own business — this one is optional,
  # so it is written without a sensor rather than refused.
  def test_a_label_naming_nothing_leaves_the_key_empty
    @session.post '/readings',
                  params: { reading: { depth: 4_242, sensor_id: 'Nowhere at all' } }

    assert_equal 303, @session.response.status
    assert_nil Reading.find_by!(depth: 4_242).sensor
  end
end
