require 'test_helper'
require 'integration_case'

# What a ticked filter submits, and what the table comes to once it has.
class TestRecoursesFilterPicks < IntegrationCase
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
end
