require 'test_helper'
require 'integration_case'

# The one record a singular resource stands for: how the gem finds it off the parent,
# where a reader goes when there is none yet or one already, and where a write lands.
class TestRecoursesSingularRecords < IntegrationCase
  # A singular resource the gem serves whole: no controller of this app's own finds the
  # record, so the gem reads it off the parent under the name the route gives it.
  def test_the_gem_reads_a_singular_record_off_its_parent
    place = Place.joins(:audit).order(:id).first
    visit "/places/#{place.id}/audit"

    assert_includes body, place.audit.finding
  end

  # And where the parent has none yet, a resource routed `new` is a form to fill in
  # rather than a page saying there is nothing — which is what `person` above gets,
  # having no `new` for the gem to send anybody to.
  def test_a_singular_with_no_record_goes_to_the_form_that_makes_one
    place = Place.where.missing(:audit).order(:id).first
    @session.get "/places/#{place.id}/audit"

    assert_equal 302, @session.response.status
    assert_equal "/places/#{place.id}/audit/new",
                 URI.parse(@session.response.headers['Location']).path
  end

  # A write on a singular resource has no index to go back to, so it lands on the one
  # page it does have: the record it just wrote.
  def test_a_write_on_a_singular_lands_on_the_record_it_wrote
    place = Place.where.missing(:audit).order(:id).first
    @session.post "/places/#{place.id}/audit", params: { audit: { finding: 'Looked in.' } }

    assert_equal 303, @session.response.status
    assert_equal "/places/#{place.id}/audit",
                 URI.parse(@session.response.headers['Location']).path
  ensure
    Audit.where(finding: 'Looked in.').destroy_all
  end

  # And the other way: at most one is what singular means, so the form that would make
  # another has nothing to make, and the reader is sent to the one already there.
  def test_a_singular_that_has_its_record_goes_to_the_page_that_reads_it
    place = Place.joins(:audit).order(:id).first
    @session.get "/places/#{place.id}/audit/new"

    assert_equal 302, @session.response.status
    assert_equal "/places/#{place.id}/audit",
                 URI.parse(@session.response.headers['Location']).path
  end
end
