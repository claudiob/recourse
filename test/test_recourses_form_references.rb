require 'test_helper'
require 'integration_case'

# How a form asks for a foreign key: a menu or a typed field, by what the key points at,
# and whether the menu offers a way to point at nothing.
class TestRecoursesFormReferences < IntegrationCase
  # A foreign key is picked or typed by what the other table can offer: three teams
  # fit in a menu, and 101 ZIPs do not — so one is a combobox and the other is a
  # field asking for the label itself, under the foreign key's own name, carrying
  # that label's length so the browser can hold it to five characters.
  def test_a_reference_is_a_menu_or_a_field_by_what_it_points_at
    visit '/places/new'

    assert_includes body, 'name="place[zip_id]"'
    # And the field says which attribute it wants, where the table's heading over the
    # same column says only what the record is: a box has to name what goes in it.
    assert_includes body, '>ZIP code</label>'
    # The label's own length and format, since that is what is being typed — and an
    # example read off the pattern, so the field names the shape it wants rather
    # than only reporting that what was typed is wrong.
    assert_includes body, 'maxlength="5" minlength="5" pattern="\d{5}"'
    assert_includes body, 'title="Please match the format 00000"'
    assert_includes body, %(data-bs-name='place[team_id]' data-controller='combobox')
    # The menu holds the labels, not the ids, and the typed one holds no menu at all.
    assert_includes body, 'Blue Crew'
    refute_includes body, '90001'
  end

  # A key that may be nothing has to be settable back to it, which a menu of records
  # cannot otherwise say. The item carries an empty value of its own, since the
  # plugin builds its hidden input from whichever item is selected — and only where
  # the model permits it: a required key offers no way to leave itself empty.
  def test_only_an_optional_menu_offers_a_way_to_choose_nothing
    visit "/places/#{Place.order(:id).first.id}/edit"

    assert_includes menu_for('place[person_id]'), %(data-bs-value='' aria-selected='false')
    assert_includes menu_for('place[person_id]'), '<span>None</span>'
    refute_includes menu_for('place[team_id]'), %(data-bs-value='' )
    # `status` is `null: false` and the model says so, so it is required too.
    refute_includes menu_for('place[status]'), %(data-bs-value='' )
  end

private

  # One combobox's menu, from its toggle to the end of its options.
  def menu_for(name)
    body[/data-bs-name='#{Regexp.escape name}'.*?combobox-no-results/m]
  end
end
