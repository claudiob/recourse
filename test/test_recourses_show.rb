require 'test_helper'
require 'integration_case'

# A record's own page, and the card the nested indexes hang off it by.
class TestRecoursesShow < IntegrationCase
  # One pass over a record carrying a value of every kind, each read out as what its
  # column holds rather than as what the database keeps: money wears its currency
  # and a percentage its sign, both decimals underneath; a float keeps its own
  # precision; a date and a time are `time` tags a browser can localize; an enum is
  # a badge and a boolean is the word, not an icon; a URL is a link to itself.
  def test_it_reads_out_a_value_of_every_kind_in_the_shape_its_column_earns
    visit "/places/#{Place.order(:id).first.id}"

    assert_includes body, '$20.00'
    assert_includes body, '5.25%'
    assert_includes body, '100.25'
    assert_includes body, '0.500'
    assert_includes body, '415-555-0000'
    # A month is the word for one, and a year the digits it is: neither counts
    # anything, so neither wears the delimiter `capacity` beside them would.
    assert_includes body, 'February'
    assert_includes body, '1991'
    refute_includes body, '1,991'
    assert_includes body, '<time datetime="2026-01-01">Jan 1, 2026</time>'
    assert_includes body, 'datetime="2026-06-01T09:30:00-04:00"'
    assert_includes body, '<span class="badge">draft'
    # Words rather than icons, and the reference read as its label either way.
    assert_includes body, 'true'
    assert_includes body, 'false'
    assert_includes body, '90001'
    assert_includes body, 'Blue Crew'
    # A URL links to itself and reads as its host: no protocol, no trailing slash.
    assert_includes body, '<a href="https://place-1.example.com"'
    assert_includes body, '>place-1.example.com <'
    # And the payload the index leaves out: a record's own page is where a value too
    # wide for a column of them still belongs.
    assert_includes body, 'step_free_access'
    # A list is the other of those, and it reads as how many before it reads as what:
    # closed, so a column of values a reader scans is not pushed down by one of them.
    assert_includes body, '<details><summary>3 items</summary><ul class="mb-0 mt-2">' \
                          '<li>Riverside</li><li>Terrace</li><li>Wheelchair access</li></ul>'
  end

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
end
