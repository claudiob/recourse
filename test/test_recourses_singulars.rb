require 'test_helper'
require 'integration_case'

# One record nested under another, drawn with `recourse` rather than `recourses`, and
# reached with no id of its own. Rails draws no index for such a resource, so the tab
# on the record it hangs off is the only thing that could lead to it.
class TestRecoursesSingulars < IntegrationCase
  # Routed `show`, a singular resource is a page: named in the singular, since there
  # is only ever one, and taking its turn among the plural tabs in routes.rb order.
  def test_a_singular_nested_show_gets_a_tab_on_its_parent
    place = Place.order(:id).first
    visit "/places/#{place.id}"

    assert_includes body, %(href="/places/#{place.id}/zip">ZIP</a>)
    # A page rather than an action, so nothing posts to it.
    refute_includes body, %(action="/places/#{place.id}/zip")
    assert_operator body.index(%(href="/places/#{place.id}/zip")), :<,
                    body.index(%(href="/places/#{place.id}/photos"))
  end

  # And the page is the place's own, card and all: this tab is the current one, the
  # place's Show and Edit tabs stand beside it unmarked, and the crumbs read back
  # through the record the path named above this one.
  def test_a_singular_nested_show_sits_in_its_parents_card
    place = Place.order(:id).first
    visit "/places/#{place.id}/zip"

    assert_includes body, %(active" aria-current="page" href="/places/#{place.id}/zip")
    assert_includes body, %(href="/places/#{place.id}/edit")
    assert_includes body, place.zip.code
    # And the crumb naming it reads as the one record it is. The path is plural, since
    # that is the controller Rails routes a singular resource to, and the word is not.
    assert_includes body, '>ZIP</span>'
    refute_includes body, 'ZIPs</span>'
  end

  # A singular resource is one the host finds, and what it finds is sometimes nothing:
  # a `belongs_to` that is optional, a `has_one` nobody has written yet. The page says
  # so in the singular, rather than reading attributes off nothing.
  def test_a_singular_nested_show_says_when_there_is_no_record
    with_person, without = Place.order(:id).partition(&:person)

    visit "/places/#{with_person.first.id}/person"
    assert_includes body, with_person.first.person.name

    visit "/places/#{without.first.id}/person"
    assert_includes body, 'No person.'
  end

  # Routed anything but a page, it is an action: the button says so and no tab claims
  # a page that is not there.
  def test_a_singular_nested_action_earns_no_tab
    place = Place.order(:id).first
    visit "/places/#{place.id}"

    refute_includes body, %(href="/places/#{place.id}/sweep")
    # The button is still there, which is the whole difference between the two.
    assert_includes body, %(action="/places/#{place.id}/sweep")
    # And one routed a page does earn a tab, which is the other half of the same rule.
    assert_includes body, %(href="/places/#{place.id}/memo")
  end

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
end
