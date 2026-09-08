require 'test_helper'
require 'integration_case'

# Moving a row of an arranged table, and what moves with it. Teams are the flat case
# and memos the nested one, so both levels are written here as well as drawn.
class TestRecoursesArrangementsWrites < IntegrationCase
  def teardown
    Team.order(:id).each_with_index { |team, index| team.update_column :position, index + 1 }
    Memo.order(:id).group_by(&:person_id).each_value do |memos|
      memos.each_with_index { |memo, index| memo.update_column :position, index + 1 }
    end
  end

  # The row moves and the block it jumped closes up behind it.
  def test_moving_a_row_up_shifts_what_it_displaced_down
    move '/teams/3/position', 1

    assert_equal ['Red Shift', 'Blue Crew', 'Green Watch', 'Night Shift'], team_names
  end

  def test_moving_a_row_down_shifts_what_it_displaced_up
    move '/teams/1/position', 3

    assert_equal ['Green Watch', 'Red Shift', 'Blue Crew', 'Night Shift'], team_names
  end

  # A drop reports where a row landed on the page it was dropped on, and a page is
  # not the table — so what a request may ask for stops at the last row.
  def test_a_place_past_the_end_is_the_end
    move '/teams/1/position', 99

    assert_equal 4, Team.find(1).position
  end

  # The rows a position counts among are the rows the route named, so one person's
  # memos renumber and nobody else's move.
  def test_a_nested_move_renumbers_that_parent_and_leaves_the_others_alone
    before = Memo.where(person_id: 2).order(:position).pluck :id

    move '/people/1/memos/3/position', 1

    assert_equal 1, Memo.find(3).position
    assert_equal before, Memo.where(person_id: 2).order(:position).pluck(:id)
  end

  # One statement however many rows it moves: a shift written a row at a time would
  # cost a query each and grow with the table.
  def test_it_shifts_every_displaced_row_in_one_statement
    writes = writes_on('teams') { move '/teams/4/position', 1 }

    assert_equal 2, writes.size
  end

  # A move made without JavaScript says so on the page it lands back on.
  def test_a_move_a_page_made_reports_itself_in_a_flash
    move '/teams/3/position', 1

    assert_equal 'Position updated', @session.flash[:notice]
  end

  # And a drag is told the same words to say for itself, since the answer it gets
  # carries nothing to render.
  def test_a_drag_is_handed_the_words_to_report_with
    @session.patch '/teams/3/position', params: { position: 1 },
                                        headers: { 'Accept' => 'application/json' }

    assert_equal 204, @session.response.status
    assert_includes visit('/teams'), 'data-sortable-message-value="Position updated"'
  end

  # A table nobody arranges at this level has no place to write, so the route that
  # exists for every resource answers nothing for it.
  def test_a_page_above_the_level_has_no_position_to_write
    assert_raises ActiveRecord::RecordNotFound do
      @session.patch '/memos/3/position', params: { position: 1 }
    end
  end

private

  def move(path, position)
    @session.patch path, params: { position: }

    assert_includes [204, 303], @session.response.status
  end

  def team_names
    Team.order(:position).pluck :name
  end
end
