require 'test_helper'

# What a model does about its own position, which is what keeps a drag honest: a drop
# reports a row's place on the page, and that is a position only while the numbers run
# 1, 2, 3 with no holes in them.
class TestRecoursesPositionable < Minitest::Test
  def teardown
    Step.where(name: 'Review').destroy_all
    Grade.where(name: 'Middling').destroy_all
  end

  # The callbacks follow the column rather than the routes, so a row made in a console
  # is numbered like one made behind a form, and the gap closes behind one that goes.
  # Both orders here: the `position` the gem keeps, and the `ranking` this app keeps
  # for the second listing of the same model.
  def test_a_new_row_lands_last_among_its_own_and_its_gap_closes_behind_it
    team = Team.order(:position).first
    person = Person.order(:id).last
    step = Step.create! name: 'Review', team: team, person: person

    assert_equal 5, step.position
    assert_equal person.steps.count, step.ranking
    step.destroy!

    assert_equal [1, 2, 3, 4], team.steps.order(:position).pluck(:position)
    assert_equal (1..person.steps.count).to_a, person.steps.order(:ranking).pluck(:ranking)
  end

  # A table with no timestamps is positioned all the same. `update_all` runs no
  # callbacks, so the shift writes `updated_at` itself where there is one — and asks
  # for no column that is not there where there is not. No page lists grades, which is
  # the other half of what this proves: the column is the opt-in, not the route.
  def test_a_table_keeping_no_timestamps_is_positioned_all_the_same
    grade = Grade.create! name: 'Middling'

    assert_equal Grade.count, grade.position
    grade.destroy!

    assert_equal (1..Grade.count).to_a, Grade.order(:position).pluck(:position)
  end

  # Which rows a position is counted among, where the model has not said: those under
  # the single key it points along, the whole table where it points nowhere, and a
  # refusal where several keys could be the parent — guessing would number a step among
  # every step there is, quietly and at the first write.
  def test_the_rows_a_position_is_counted_among_default_to_the_one_key
    siblings = Recourse::Positionable.instance_method :recourse_siblings
    shift = Shift.order(:id).first

    assert_equal Shift.where(person: shift.person).to_sql, siblings.bind(shift).call.to_sql
    assert_equal Team.all.to_sql, siblings.bind(Team.order(:position).first).call.to_sql
    error = assert_raises Recourse::Error do
      siblings.bind(Step.order(:id).first).call
    end

    assert_includes error.message, 'Answer `recourse_siblings`'
  end

  # A host keeping its own order of its own says so by answering no column at all,
  # which takes the grip off the table and both callbacks off the model together.
  def test_a_model_may_answer_no_position_at_all
    unpositioned = Class.new(Team) { def self.recourse_position = nil }

    assert_nil Recourse.position_column(unpositioned)
    refute Recourse.positioned?(unpositioned, nil)
    # And the order falls back with it: a table nobody positions is read in the order
    # its rows were made.
    assert_equal :id, unpositioned.recourse_order
  end
end
