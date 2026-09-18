require 'test_helper'
require 'integration_case'

# The table somebody drags into order: the grip it draws, and the controls it stands
# down for as long as one is drawn.
class TestRecoursesArrangements < IntegrationCase
  # A flat table — teams point nowhere — is arranged among the whole of itself, so its
  # own index is the level a place in it means anything at. The grip leads each row,
  # the body says what a drop is counted from, and every row says where to write one.
  def test_a_flat_index_draws_a_grip_on_every_row
    visit '/teams'

    assert_includes body, '<tbody data-controller="sortable" data-sortable-offset-value="0"'
    assert_includes body, 'data-sortable-message-value="Position updated"'
    Team.order(:position).each do |team|
      assert_includes body, %(data-sortable-update-url="/teams/#{team.id}/position")
    end
    # The icon on the header row, the column being as narrow as what sits in it, and
    # the word in the cell below for the label a stacked table reads itself by.
    assert_includes body, '<i class="bi bi-grip-vertical" aria-label="Reorder"'
    assert_includes body, '<td data-cell="Reorder" class="recourse-actions recourse-handle">'
  end

  # And it draws nothing a reader could reorder it with. A drop reports a row's place
  # on the page, which is a position only while the page runs 1, 2, 3: a heading that
  # re-sorted it or a filter that shortened it would leave the next drag renumbering by
  # the wrong index. Refused rather than merely left off the page, an address being
  # typed as readily as it is clicked.
  def test_an_arranged_table_stands_its_search_and_its_headings_down
    sql = queries_on('teams') { visit '/teams' }

    assert_includes sql.last, 'ORDER BY "teams"."position" ASC'
    assert_includes body, '<th scope="col">Name</th>'
    refute_includes body, 'q%5Bs%5D'
    refute_includes body, 'name="q[name_cont]"'
    sql = queries_on('teams') { visit '/teams?q%5Bs%5D=name+desc&q%5Bname_cont%5D=Blue' }

    assert_includes sql.last, 'ORDER BY "teams"."position" ASC'
    assert_includes body, 'Green Watch'
  end

  # The column itself is off every screen. The row's own place in the table is what
  # says it, so a column of figures beside the grips would be the same fact written
  # out — and no form asks for one, a position being set by dragging a row.
  def test_the_position_is_neither_drawn_nor_typed
    visit '/teams'

    refute_includes body, 'data-cell="Position"'
    visit "/teams/#{Team.order(:position).first.id}/edit"

    refute_includes body, 'name="team[position]"'
    refute_includes Recourse.editable_columns(Team), 'position'
  end

  # A table pointing somewhere is arranged within what it points at, so the grip is
  # drawn on the index nested under that parent and on no other: a listing of every
  # step across every team is one where the positions run 1, 2, 3, 1, 2, 3 and mean
  # nothing side by side, and it sorts and searches like any other page.
  def test_a_nested_index_is_arranged_and_the_same_model_listed_flat_is_not
    team = Team.order(:position).first
    visit "/teams/#{team.id}/steps"

    assert_includes body, 'data-controller="sortable"'
    # And the page is drawn in the order somebody put the rows in, which is the whole
    # of what makes a drop's own index a position.
    assert_equal team.steps.order(:position).pluck(:name),
                 body.scan(/data-cell="Name">([^<]+)</).flatten
    refute Recourse.arranges?(Step, nil)
    assert Recourse.arranges?(Step, Step.reflect_on_association(:team))
  end

  # The second listing of an arranged model, dragged into order by a column the model
  # does not keep: a step holds a place among its team's steps and another among the
  # steps of whoever is to do them, and which of the two a page is in is the page's
  # answer. The order the rows are read in follows the column the page names, or a drop
  # would report a place the write could not use.
  def test_a_host_may_arrange_a_listing_by_a_column_of_its_own
    person = Person.order(:id).first
    sql = queries_on('steps') { visit "/people/#{person.id}/steps" }

    assert_includes sql.last, 'ORDER BY "steps"."ranking" ASC'
    assert_includes body, 'data-controller="sortable"'
    assert_includes body, %(data-sortable-update-url="/people/#{person.id}/steps/)
    # Both columns are off the table: the model's own, and the one this page names.
    refute_includes body, 'data-cell="Ranking"'
    refute_includes body, 'data-cell="Position"'
  end

  # A model keeping no such column is a table nobody arranges, whatever level it is
  # read at: no grip, and its headings and its search box stand as they were.
  def test_a_table_with_no_position_column_arranges_nothing
    visit '/places'

    refute_includes body, 'data-controller="sortable"'
    assert_includes body, 'href="/places?q%5Bs%5D=name+desc">Name</a></th>'
    assert_nil Recourse.position_column(Place)
    refute Recourse.arrangeable?(Place)
  end
end
