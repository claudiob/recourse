require 'test_helper'
require 'integration_case'

# Whose clock a page is read against. Exempt from "as few tests as coverage needs":
# the same lines run whether a timestamp lands in the reader's zone or nine hours
# off it, so no covered line stands in for any of these.
class TestRecoursesZones < IntegrationCase
  TOKYO = 'Asia/Tokyo'

  def teardown
    Place.find(place.id).update! audited_at: Time.utc(2026, 6, 1, 13, 30)
  end

  # The same instant, in the zone the browser named — and the date beside it unmoved,
  # since a date is a day rather than a moment and has no hour to shift.
  def test_it_reads_a_timestamp_against_the_zone_the_browser_named
    visit "/places/#{place.id}"

    assert_includes body, '>Jun 1 at 09:30am EDT</time>'

    zoned TOKYO
    visit "/places/#{place.id}"

    assert_includes body, '>Jun 1 at 10:30pm JST</time>'
    assert_includes body, '<time datetime="2026-01-01">Jan 1, 2026</time>'
  end

  # A zone nothing answers to leaves the host's own standing, so a forged cookie draws
  # the page every reader saw before any of this.
  def test_it_falls_back_to_the_hosts_zone_where_the_cookie_names_none
    zoned 'Mars/Olympus'
    visit "/places/#{place.id}"

    assert_includes body, '>Jun 1 at 09:30am EDT</time>'
  end

  # And the form agrees with the page beside it, on the way out and on the way back:
  # a field is filled in the reader's zone and read back in it, so the row keeps the
  # instant it would have kept had they been sitting in the host's.
  def test_a_form_offers_and_stores_the_instant_the_page_showed
    zoned TOKYO
    visit "/places/#{place.id}/edit"

    assert_includes body, 'value="2026-06-01T22:30:00" type="datetime-local"'

    @session.patch "/places/#{place.id}", params: { place: { audited_at: '2026-06-02T09:00' } }

    assert_equal Time.utc(2026, 6, 2, 0, 0), place.reload.audited_at.utc
  end

private

  def zoned(name) = @session.cookies[Recourse::ZONE_STORAGE] = name

  def place = @place ||= Place.order(:id).first
end
