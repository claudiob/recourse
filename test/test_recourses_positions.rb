require 'test_helper'
require 'integration_case'

# What a drop writes: the row lands where it was dropped, whatever it displaced shifts
# one step the other way, and the table still runs 1, 2, 3 afterwards.
class TestRecoursesPositions < IntegrationCase
  # Down the table and back up again, which are the two ranges: moving down, the block
  # above the row shifts up; moving up, the block beneath it shifts down. Answered with
  # nothing at all — the row is already where it was dropped, and redrawing the table
  # under the cursor that dropped it is what that avoids.
  def test_a_drop_lands_the_row_and_shifts_what_it_displaced
    team = Team.order(:position).first
    names = arrangement_of team
    drop first_step_of(team), team, 3

    assert_equal 204, @session.response.status
    assert_equal names.values_at(1, 2, 0, 3), arrangement_of(team)
    assert_equal (1..names.size).to_a, team.steps.order(:position).pluck(:position)
    drop team.steps.order(:position).third, team, 1

    assert_equal names, arrangement_of(team)
  end

  # Never past the end: a drag reports where a row was dropped, and a page is not the
  # whole table. And a drop where the row already stands writes nothing at all, which
  # is what leaves the rows' own versions — and the table a fragment cache keeps — as
  # they were.
  def test_a_drop_is_clamped_to_the_table_and_a_drop_in_place_writes_nothing
    team = Team.order(:position).second
    names = arrangement_of team
    drop first_step_of(team), team, 99

    assert_equal names.rotate(1), arrangement_of(team)
    written = versions_of team
    drop team.steps.order(:position).last, team, names.size

    assert_equal written, versions_of(team)
    drop team.steps.order(:position).last, team, 1
  end

  # A flat table is arranged among the whole of itself, so the route sits under the
  # resource's own index and the rows renumbered are every row there is.
  def test_a_flat_table_is_dragged_at_its_own_index
    team = Team.order(:position).last
    @session.patch "/teams/#{team.id}/position", params: { position: 1 }

    assert_equal 204, @session.response.status
    assert_equal 1, team.reload.position
    assert_equal (1..Team.count).to_a, Team.order(:position).pluck(:position)
    @session.patch "/teams/#{team.id}/position", params: { position: Team.count }
  end

  # The second listing of an arranged model writes the column its own page named and
  # leaves the one the model keeps alone: a step's place among its team's steps and its
  # place among one person's are two facts, and a page is in one order or the other.
  def test_a_hosts_own_listing_writes_the_column_it_arranged_by
    person = Person.joins(:steps).group('people.id').order('count(steps.id) desc').first
    steps = person.steps.order(:ranking).to_a
    step = steps.first
    @session.patch "/people/#{person.id}/steps/#{step.id}/position", params: { position: 2 }

    assert_equal 204, @session.response.status
    assert_equal [steps[1], step, *steps[2..]].map(&:id), person.steps.order(:ranking).pluck(:id)
    assert_equal step.position, step.reload.position
    @session.patch "/people/#{person.id}/steps/#{step.id}/position", params: { position: 1 }
  end

  # A table nobody arranges draws no grip, so the only way to its write is by hand —
  # which earns a 404 rather than a 500 from somewhere below.
  def test_a_table_nobody_arranges_refuses_the_write
    place = Place.order(:id).first

    assert_raises ActiveRecord::RecordNotFound do
      @session.patch "/places/#{place.id}/position", params: { position: 1 }
    end
  end

private

  def drop(step, team, position)
    @session.patch "/teams/#{team.id}/steps/#{step.id}/position", params: { position: }
  end

  def first_step_of(team) = team.steps.order(:position).first

  def arrangement_of(team) = team.steps.order(:position).pluck(:name)

  def versions_of(team) = team.steps.order(:position).pluck :updated_at
end
