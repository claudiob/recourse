require 'test_helper'
require 'integration_case'

# The menus beside the search box: what each one offers, what a tick submits, and
# what the table comes to once one is ticked.
class TestRecoursesFilters < IntegrationCase
  # A menu per enum and one per foreign key the box does not reach through instead,
  # each submitting a list predicate so more than one may be ticked at once.
  def test_a_filter_narrows_by_an_enum_and_by_a_reference
    visit '/places'

    # Each a plain multiple select the design bundle dresses, named with `[]` so every
    # pick is submitted the way Ransack reads a list predicate.
    assert_includes body, '<select name="q[status_in][]" id="q_status_in" multiple="multiple" ' \
                          'class="form-select form-select-sm" aria-label="Status" ' \
                          'data-controller="combobox" data-combobox-placeholder-value="Status"'
    # A boolean admits two values, so it is a menu for the same reason an enum is —
    # and the way back is the bare `All`, since `signeds` is nothing anybody writes.
    assert_includes body, 'name="q[active_in][]"'
    assert_includes menu_for('q[active_in][]'), '<option value="true">true</option>'
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

  # What a tick comes to: the rows the picks name and no others. Every pick is
  # submitted as a value of its own — `q[team_id_in][]=1&q[team_id_in][]=2` — and
  # read as the comma-joined string a combobox submitted before it was a `<select>`,
  # the array came back as the single value `["1"]`, which Ransack cast to an id no
  # row holds: every filtered table in the gem read as empty.
  def test_a_filter_narrows_the_table_to_the_picks_a_request_carries
    blue, green = Team.order(:id).first 2
    visit "/places?q%5Bteam_id_in%5D%5B%5D=#{blue.id}"

    assert_includes body, 'Place 01'
    refute_includes body, 'Place 02'
    # More than one at once is what the shape is for, and both reach the table.
    visit "/places?q%5Bteam_id_in%5D%5B%5D=#{blue.id}&q%5Bteam_id_in%5D%5B%5D=#{green.id}"

    assert_includes body, 'Place 01'
    assert_includes body, 'Place 02'
    refute_includes body, 'Place 03'
    # And `All teams` — one empty value — is no filter at all rather than a filter
    # nothing answers, which is what an `IN ()` of its own would have been.
    visit '/places?q%5Bteam_id_in%5D%5B%5D='

    assert_includes body, 'Place 03'
  end

  # A menu over a predicate no column of the model describes -- a word reached through
  # another table, or anything else Ransack can ask that a schema says nothing about.
  # The host names the words, and names the menu too: there is no column to head it.
  def test_a_filter_offers_the_words_a_host_named_for_a_predicate_no_column_describes
    crew = Team.order(:name).first
    visit '/places'
    menu = menu_for 'q[team_name_in][]'

    assert_includes menu, 'aria-label="Crew"'
    assert_includes menu, 'data-combobox-all-value="All crews"'
    assert_includes menu, %(<option value="#{crew.name}">#{crew.name}</option>)
    # And it narrows: the words go back as they came, and Ransack reaches through.
    visit "/places?q%5Bteam_name_in%5D%5B%5D=#{CGI.escape crew.name}"

    assert_equal crew.places_count, body.scan('data-cell="Name"').size
  end

private

  # One combobox's select, from its opening tag to its closing one.
  def menu_for(name)
    body[%r{<select name="#{Regexp.escape name}".*?</select>}m]
  end
end
