require 'test_helper'
require 'integration_case'

# A list of values goes out one to a line and comes back the same way. Exempt from
# "as few tests as coverage needs" only in where it sits: the round trip is the one
# thing about a list no page renders, so no test that draws one reaches it.
class TestRecoursesLists < IntegrationCase
  def teardown
    place.update_column :tags, ['Riverside', 'Terrace', 'Wheelchair access']
  end

  # Typed as lines and stored as values, with the blank ones dropped: an empty line is
  # somebody pressing return, not a value they meant to keep.
  def test_a_list_is_typed_one_value_to_a_line_and_stored_as_its_values
    @session.patch "/places/#{place.id}", params: { place: { tags: "Sauna\n \nRoof deck\n" } }

    assert_equal ['Sauna', 'Roof deck'], place.reload.tags
  end

  # And an emptied box empties the list rather than leaving one blank string in it.
  def test_an_emptied_box_leaves_no_value_behind
    @session.patch "/places/#{place.id}", params: { place: { tags: '' } }

    assert_empty place.reload.tags
  end

private

  def place = @place ||= Place.order(:id).first
end
