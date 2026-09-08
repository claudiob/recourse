require 'test_helper'
require 'integration_case'

# A bare action with a model behind it and no form: what its button says, and where a
# write it refuses lands.
class TestRecoursesRefusals < IntegrationCase
  # The button stands on the record's own page. A bare action has no form to send a
  # refusal back to, so what turned the write down is said in a flash on the page the
  # button was on — the model's own words rather than the gem's `could not be created`,
  # which names the model and not the reason.
  def test_a_refused_bare_action_says_why_where_its_button_was
    sealed = Seal.order(:id).first.place
    visit "/places/#{sealed.id}"

    assert_includes body, %(action="/places/#{sealed.id}/seals")
    assert_includes body, 'Add seal'
    @session.post "/places/#{sealed.id}/seals"

    assert_equal 303, @session.response.status
    assert_equal "http://localhost/places/#{sealed.id}", @session.response.location
    assert_equal 'Place has already been taken', @session.request.flash[:alert]
    assert_equal 1, Seal.where(place: sealed).count
  end
end
