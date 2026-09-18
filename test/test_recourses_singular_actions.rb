require 'test_helper'
require 'integration_case'

# Where a singular resource's button stands, and which of the two verbs it offers.
class TestRecoursesSingularActions < IntegrationCase
  # A singular resource has a page of its own, so its button stands there instead --
  # and which of the two verbs it offers is the record's to say, a `has_one` answering
  # only one of them: there is nothing to add where there is already one, and nothing
  # to delete where there is none.
  def test_a_singular_resource_offers_its_action_on_its_own_page_alone
    sealed = Seal.order(:id).first.place
    unsealed = Place.where.missing(:seal).order(:id).first

    visit "/places/#{unsealed.id}/seal"

    assert_includes body, 'No seal.'
    assert_includes body, 'Add seal'
    refute_includes body, 'Delete seal'

    visit "/places/#{sealed.id}/seal"

    assert_includes body, 'Delete seal'
    refute_includes body, 'Add seal'

    # And neither of them on the place's own page, which carries the tab leading here
    visit "/places/#{sealed.id}"

    assert_includes body, %(href="/places/#{sealed.id}/seal")
    refute_includes body, %(action="/places/#{sealed.id}/seal")
  end

  # A bare action has no form to send a refusal back to, its button standing on a page
  # about something else, so what turned the write down is said in a flash on the page
  # the button was on. The model's own words rather than the gem's `could not be
  # created`, which names the model and not the reason.
  def test_a_refused_bare_action_says_why_where_its_button_was
    sealed = Seal.order(:id).first.place
    @session.post "/places/#{sealed.id}/seal"

    assert_equal 303, @session.response.status
    assert_equal "http://localhost/places/#{sealed.id}/seal", @session.response.location
    assert_equal 'Place has already been taken', @session.request.flash[:alert]
    assert_equal 1, Seal.where(place: sealed).count
  end
end
