require 'test_helper'
require 'integration_case'

# A table whose rows keep a place ID or a point can be read as a Google map of the same page.
class TestRecoursesMaps < IntegrationCase
  # The footer offers the map where there is one to offer, and the map the table back,
  # each keeping the page the other was on. Exempt from "as few tests as coverage
  # needs": the link runs the same lines whichever address it carries.
  def test_a_table_of_places_and_its_map_each_lead_to_the_other
    visit '/readings?page=7'

    assert_includes body, %(href="/readings.map?page=7">Display as map</a>)
    refute_includes body, 'data-controller="map"'

    visit '/readings.map?page=14'

    assert_includes body, %(href="/readings?page=14">Display as table</a>)
    assert_includes body, 'data-controller="map"'
    # This page's rows and no others, in the order the table reads them — deepest first.
    # A reading is no geography, so its places are pins: no layer is named.
    first, last = Reading.find(6, 1).map(&:google_place_id)

    assert_includes body, %(data-map-places-value="[&quot;#{first}&quot;,)
    assert_includes body, %(&quot;#{last}&quot;]")
    refute_includes body, 'data-map-boundary-value'
    assert_includes body, 'Displaying items 196-201 of 201'
    refute_includes body, '<table'
  end

  # A ZIP is one of the geographies Google draws a boundary for, so its places are areas
  # on that layer — by the model's own name, with nothing declared.
  def test_a_table_of_zips_is_drawn_as_postal_areas
    visit '/zips.map'

    assert_includes body, 'data-map-boundary-value="POSTAL_CODE"'
    first = ZIP.find_by!(code: '90001').google_place_id

    assert_includes body, %(data-map-places-value="[&quot;#{first}&quot;,)
  end

  # A row keeping coordinates rather than a place is pinned as it is, no lookup.
  def test_a_table_of_points_is_drawn_as_pins
    visit '/places.map'

    assert_includes body, 'data-map-points-value="[[37.'
    assert_includes body, ',-122.'
    refute_includes body, 'data-map-places-value'
  end

  def test_a_table_of_rows_with_neither_place_nor_point_offers_no_map
    visit '/teams'

    refute_includes body, 'Display as map'
  end

  # Which shape a page is in is the page's own business rather than the request's. A
  # table asked for as a Turbo Stream -- which is how a page redraws after a write --
  # is still a table, and reading the shape off the format offered `Display as table`
  # on the table being read.
  def test_a_table_asked_for_as_a_stream_offers_no_link_to_itself
    stream = 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml'
    @session.get '/people', headers: { 'HTTP_ACCEPT' => stream }

    assert_includes body, 'Displaying'
    refute_includes body, 'Display as table'
  end
end
