require 'test_helper'
require 'integration_case'

# The menus beside the search box: what each one offers, what a tick submits, and
# what the table comes to once one is ticked.
class TestRecoursesFilters < IntegrationCase
  # A menu per enum and one per foreign key the box does not reach through instead,
  # each submitting a list predicate so more than one may be ticked at once.
  def test_a_filter_narrows_by_an_enum_and_by_a_reference
    visit '/places'

    assert_includes body, "data-bs-name='q[status_in]'"
    # A boolean admits two values, so it is a menu for the same reason an enum is —
    # and the way back is the bare `All`, since `signeds` is nothing anybody writes.
    assert_includes body, "data-bs-name='q[active_in]'"
    assert_includes menu_for('q[active_in]'), "data-bs-value='true'"
    assert_includes menu_for('q[active_in]'), '>All</button>'
    assert_includes body, "data-bs-name='q[team_id_in]'"
    # No menu for the ZIP: 101 rows are more than a menu offers, so the box reaches
    # through that key instead and a filter would only ask the same thing twice.
    refute_includes body, "data-bs-name='q[zip_id_in]'"
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
    menu = body[/data-bs-name='q\[team_id_in\]'.*?combobox-no-results/m]

    assert_includes menu, "d-none' type='button' data-bs-value='#{empty.id}'"
    assert_includes menu, 'All teams'
    refute_includes menu, "d-none' type='button' data-bs-value='#{Team.order(:id).first.id}'"
    # Ticked, it stays on the menu however few rows are behind it.
    visit "/places?q%5Bteam_id_in%5D=#{empty.id}"
    menu = body[/data-bs-name='q\[team_id_in\]'.*?combobox-no-results/m]

    refute_includes menu, "d-none' type='button' data-bs-value='#{empty.id}'"
  end

private

  # One combobox's menu, from its toggle to the end of its options.
  def menu_for(name)
    body[/data-bs-name='#{Regexp.escape name}'.*?combobox-no-results/m]
  end
end
