require 'test_helper'
require 'integration_case'

# The menus beside the search box, and what each one offers to narrow by.
class TestRecoursesFilters < IntegrationCase
  # A menu per enum and one per foreign key the box does not reach through instead,
  # each submitting a list predicate so more than one may be ticked at once.
  def test_a_filter_narrows_by_an_enum_and_by_a_reference
    visit '/places'

    # Each a plain multiple select the design bundle dresses, named with `[]` so every
    # pick is submitted the way Ransack reads a list predicate.
    assert_includes body, '<select name="q[status_in][]" id="q_status_in" multiple="multiple" ' \
                          'class="form-control form-control-sm" aria-label="Status" ' \
                          'data-controller="combobox" data-combobox-placeholder-value="Status"'
    # A boolean admits two values, so it is a menu for the same reason an enum is —
    # read as a reader reads them, and with the bare `All` as the way back, since
    # `actives` is nothing anybody writes.
    assert_includes body, 'name="q[active_in][]"'
    assert_includes menu_for('q[active_in][]'), '<option value="true">Yes</option>'
    assert_includes menu_for('q[active_in][]'), '<option value="false">No</option>'
    assert_includes menu_for('q[active_in][]'), 'data-combobox-all-value="All"'
    assert_includes body, 'name="q[team_id_in][]"'
    # No menu for the ZIP: 201 rows are more than a menu offers, so the box reaches
    # through that key instead and a filter would only ask the same thing twice.
    refute_includes body, 'q[zip_id_in]'
    visit "/places?q%5Bstatus_in%5D=#{Place.statuses.keys.last}"

    assert_includes body, Place.statuses.keys.last
    refute_includes body, '<span class="badge">draft</span>'
  end

  # A menu counts what each option would narrow to, and an option that would narrow
  # to nothing is in the menu but not on it — until `All …` asks for it, which is
  # also the way back to no filter at all. One already ticked stays put regardless,
  # or the box would name a filter its own menu does not offer.
  def test_a_filter_hides_the_options_that_would_narrow_to_nothing
    empty = Team.order(:id).last
    visit '/places'
    menu = menu_for 'q[team_id_in][]'

    assert_includes menu, %(<option value="#{empty.id}" data-count="0" data-hidden="">)
    assert_includes menu, 'data-combobox-all-value="All teams"'
    refute_includes menu, %(<option value="#{Team.order(:id).first.id}" data-count="0")
    # Ticked, it stays on the menu however few rows are behind it.
    visit "/places?q%5Bteam_id_in%5D%5B%5D=#{empty.id}"
    menu = menu_for 'q[team_id_in][]'

    assert_includes menu, %(<option value="#{empty.id}" selected="selected" data-count="0">)
    # Under a record the counts are of the whole table, not of the record's share of
    # it, so the menu carries none, hides nothing, and reads in name order.
    visit "/people/#{Person.order(:id).first.id}/places"
    menu = menu_for 'q[team_id_in][]'

    refute_includes menu, 'data-count'
    refute_includes menu, 'data-hidden'
  end
end
