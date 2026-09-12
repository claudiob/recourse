require 'test_helper'
require 'integration_case'

# The box above a table: what it looks through, what a match earns, and the order
# a heading asked for. The menus beside it are `TestRecoursesFilters`.
class TestRecoursesSearch < IntegrationCase
  # What the box looks through is decided by the indexes, and it says so while it is
  # empty. A match is marked, and only in a column the search actually read — a mark
  # anywhere else would claim a match that never happened.
  def test_the_box_searches_the_indexed_columns_and_marks_what_it_matched
    visit '/places'

    # Its own two indexed strings, and the label behind the one foreign key the
    # box reaches through rather than lists — an acronym keeping its capitals.
    assert_includes body, 'name="q[name_or_slug_or_zip_code_cont]"'
    assert_includes body, 'placeholder="Filter by name or slug or ZIP code"'
    visit '/places?q%5Bname_or_slug_or_zip_code_cont%5D=Place+01'

    assert_includes body, '<mark>Place 01</mark>'
    # One row matched, so nothing else is on the page to be marked.
    refute_includes body, 'Place 02'
  end

  # A heading that sorted the table says which way, with a caret; the others say
  # nothing, because an arrow on every heading says nothing about the order in force.
  def test_the_sorted_heading_wears_the_caret_and_no_other_does
    sql = queries_on('places') { visit '/places?q%5Bs%5D=name+desc' }

    # Whichever way the rows run, the ones with nothing in the column come last.
    assert_includes sql.last, 'ORDER BY "places"."name" DESC NULLS LAST'
    assert_includes body, 'bi bi-caret-down-fill'
    refute_includes body, 'bi bi-caret-up-fill'
    # Sorted downward already, so the heading's next click turns the table back up.
    assert_includes body, 'href="/places?q%5Bs%5D=name+asc">Name'
    # And a search keeps the order a heading asked for, carried as a hidden field.
    assert_includes body, '<input type="hidden" name="q[s]" id="q_s" value="name desc"'
    # Indexed, so it is a column a heading could sort by; hidden by the model, so none
    # may. No page can show this -- a hidden column has no heading to look at -- which
    # is why it is asserted on the list rather than on the markup.
    refute_includes Place.ransortable_attributes, 'webhook_url'
  end

  # A host's row may draw a column of the record a key points at, and mark it with the
  # same helper: the search looked through that label, so the mark is honest. Its own
  # column is marked as before, and one the search never read is not.
  def test_a_label_reached_through_a_key_is_marked_in_a_hosts_own_row
    person = Person.order(:id).find { |one| one.places.any? }
    code = person.places.first.zip.code
    visit "/people/#{person.id}/places?q%5Bname_or_slug_or_zip_code_cont%5D=#{code}"

    assert_includes body, %(data-cell="ZIP"><mark>#{code}</mark></td>)
  end

  # And the model's own order ends the same way: `{ depth: :desc }` reads as Arel with
  # the empty rows last, where a SQL string a host wrote would be taken as written.
  def test_the_models_own_order_puts_the_empty_rows_last
    sql = queries_on('readings') { visit '/readings' }

    assert_includes sql.last, 'ORDER BY "readings"."depth" DESC NULLS LAST'
  end
end
