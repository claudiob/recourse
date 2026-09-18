require 'test_helper'
require 'integration_case'

# What a kept table notices. Exempt from "as few tests as coverage needs": the same
# lines run whether a fragment is served again or drawn from scratch, so no covered
# line stands in for either of these.
class TestRecoursesCaching < IntegrationCase
  def setup
    Rails.cache.clear
    # Asked once per class per process, and the second test counts what a request
    # costs. Left to chance it lands in whichever test reaches this table first.
    ZIP.recourse_listable?
    super
  end

  # A cell naming a key draws the record it points at, and the relation's own version
  # — `COUNT(*)` and `MAX(updated_at)` over the page — never sees that record: editing
  # a ZIP moves no place's `updated_at`, so the table would keep the code it was
  # written with until somebody wrote to a place.
  def test_a_table_redraws_when_a_record_its_rows_draw_is_edited
    zip = Place.order(:id).first.zip
    code = zip.code
    visit '/places'

    assert_includes body, code

    zip.update! code: '99999'
    visit '/places'

    assert_includes body, '99999'
  ensure
    zip.update! code: code
  end

  # A counter cache is written by `update_counters`, which moves no timestamp, so the
  # version above calls the row unchanged and the table would go on showing the number
  # it was cached with. The counts the rows draw are in the key for that reason.
  def test_a_table_redraws_when_a_count_its_rows_draw_changes
    person = Person.order(:id).first
    place = Place.where.not(person: person).order(:id).first
    owner = place.person
    visit '/people'

    assert_includes body, %(aria-label="#{person.places_count} Places")

    place.update! person: person
    visit '/people'

    assert_includes body, %(aria-label="#{person.reload.places_count} Places")
  ensure
    place&.update! person: owner
  end

  # And the version is read off the records the index eager-loaded rather than asked
  # for: the ZIPs of a page are fetched once, for the cells that name them.
  def test_reading_that_version_costs_no_query_of_its_own
    queries = queries_on('zips') { visit '/places' }

    assert_match(/\ASELECT "zips"/, queries.sole)
  end
end
