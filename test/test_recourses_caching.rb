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

  # And the version is read off the records the index eager-loaded rather than asked
  # for: the ZIPs of a page are fetched once, for the cells that name them.
  def test_reading_that_version_costs_no_query_of_its_own
    queries = queries_on('zips') { visit '/places' }

    assert_match(/\ASELECT "zips"/, queries.sole)
  end
end
