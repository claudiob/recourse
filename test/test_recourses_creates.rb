require 'test_helper'
require 'integration_case'

# What `create` does with a record that saves, and with one that will not.
class TestRecoursesCreates < IntegrationCase
  def teardown
    Place.where(slug: 'a-new-place').destroy_all
  end

  # A typed reference arrives as the label somebody typed rather than as an id, and
  # `create` looks it up under the foreign key's own name — so no host model needs a
  # virtual attribute and strong parameters need no special case.
  def test_create_looks_up_a_typed_reference_and_returns_to_the_index
    @session.post '/places', params: { place: new_place_params }

    assert_equal 303, @session.response.status
    assert_equal '/places', URI.parse(@session.response.headers['Location']).path
    place = Place.find_by! slug: 'a-new-place'

    assert_equal ZIP.find_by!(code: '90002'), place.zip
    follow_and_assert_flash 'Place was created.'
    # The page is told which row the write landed on, so it can mark it for as long as
    # the message stands — and told as data rather than as a second message: every
    # other key in the flash becomes a toast of its own, whoever invented it.
    assert_includes body, %(data-written-row-value="place_#{place.id}")
    refute_includes body, "place_#{place.id}</span>"
  end

  # A record that will not save redraws its own form rather than redirecting, with
  # the message beside the field that earned it and Bootstrap's own two classes on
  # the pair — which the host app's `field_error_proc` is what supplies.
  def test_a_rejected_record_redraws_the_form_with_the_message_beside_the_field
    rejected = new_place_params.merge name: '', team_id: '', zip_id: '00000'
    @session.post '/places', params: { place: rejected }

    assert_equal 422, @session.response.status
    assert_includes body, 'is-invalid'
    assert_includes body, '<small class="invalid-feedback"'
    assert_includes body, 'Can&#39;t be blank'
    # Neither a combobox nor a typed reference is a form builder's tag, so
    # `field_error_proc` never sees either: each draws its own message, and both
    # have to say what the builder's fields would have said.
    assert_equal 2, body.scan('Must exist').size
    # A code matching nothing was never assigned, so only the request still knows
    # what was typed — and that is what the field has to keep showing.
    assert_includes body, 'value="00000"'
    # An error outranks a hint. The ZIP has both a comment and a message, and it points
    # at the message alone — the note is still drawn, and nothing describes it. Which
    # is also what keeps `field_error_proc` — a host's, and untouched by any of this —
    # from writing a second `aria-describedby` beside one of ours.
    assert_includes body, 'aria-describedby="place_zip_id_error"'
    refute_includes body, 'aria-describedby="place_zip_id_help"'
    assert_includes body, 'id="place_zip_id_help"'
  end

private

  def new_place_params
    { zip_id: '90002', team_id: Team.order(:id).first.id, name: 'A new place',
      slug: 'a-new-place', capacity: 10, status: 'draft', active: '1', }
  end
end
