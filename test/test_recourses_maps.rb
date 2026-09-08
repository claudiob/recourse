require 'test_helper'
require 'integration_case'

# A table whose rows keep a place ID can be read as a Google map of the same page.
class TestRecoursesMaps < IntegrationCase
  # The footer offers the map where there is one to offer, and the map the table back,
  # each keeping the page the other was on. Exempt from "as few tests as coverage
  # needs": the link runs the same lines whichever address it carries.
  def test_a_table_of_places_and_its_map_each_lead_to_the_other
    visit '/readings?page=6'

    assert_includes body, %(href="/readings.map?page=6">Display as map</a>)
    refute_includes body, 'data-controller="map"'

    visit '/readings.map?page=6'

    assert_includes body, %(href="/readings?page=6">Display as table</a>)
    assert_includes body, 'data-controller="map"'
    assert_includes body, %(data-map-places-value="[&quot;ChIJ101&quot;]")
    assert_includes body, 'Displaying items 101-101 of 101 in total'
    refute_includes body, '<table'
  end

  def test_a_table_of_rows_with_no_place_offers_no_map
    visit '/zips'

    refute_includes body, 'Display as map'
  end
end
