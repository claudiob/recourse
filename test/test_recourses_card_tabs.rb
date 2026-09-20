require 'test_helper'
require 'integration_case'

# The card a record's own page sits in, and the tabs the nested indexes hang off it by.
class TestRecoursesCardTabs < IntegrationCase
  # The card a record's own page sits in: its Show tab first, then one tab per index
  # nested under it, in the order routes.rb nested them rather than the order the
  # associations were declared. A counter cache decides how a tab reads and never
  # whether it is there — Places carries one, Memos does not.
  def test_the_card_tabs_follow_the_routes_and_read_by_what_is_counted
    person = Person.order(:id).first
    visit "/people/#{person.id}"

    assert_includes body, %(href="/people/#{person.id}/places">)
    # The words wrapped, so a phone keeps the icon and the figure and drops them.
    assert_includes body, %(#{person.places_count} <span class="recourse-tab-word">places</span>)
    assert_includes body, %(href="/people/#{person.id}/memos">)
    assert_includes body, '</i> <span class="recourse-tab-word">Memos</span></a>'
    # The tab order is the routes file's: places was nested first. By href, since a
    # bare action's button carries a path of its own before the tabs are drawn.
    assert_operator body.index(%(href="/people/#{person.id}/places")), :<,
                    body.index(%(href="/people/#{person.id}/memos"))
  end

  # And a tab named after the route is named the way the sidebar names the same
  # resource: the model's own word, not what the path humanizes to.
  def test_a_tab_with_no_association_behind_it_takes_the_model_word
    person = Person.order(:id).first
    visit "/people/#{person.id}"

    tab = %(<i class="bi bi-geo-alt"></i> <span class="recourse-tab-word">ZIPs</span>)

    assert_includes body, %(href="/people/#{person.id}/zips">#{tab}</a>)
  end

  # A model keeping no column to be named by: `recourse_label` points at one it does not
  # have, and the crumb over the page would have been blank. What the record prints
  # itself as names it instead.
  def test_a_record_with_no_label_column_is_named_by_what_it_prints_as
    seal = Seal.order(:id).first
    visit "/places/#{seal.place_id}/seal"

    assert_includes body, "#{seal.place.name}, sealed"
  end
end
