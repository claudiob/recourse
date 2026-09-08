require 'test_helper'
require 'integration_case'

# What a model says by marking one key of `recourse_order` `:positionable`, what it
# is refused for saying it badly, and which of its pages the saying applies to.
class TestRecoursesPositions < IntegrationCase
  def test_a_marked_key_names_the_column_a_table_is_arranged_by
    assert_equal 'position', Recourse.position_column(Team)
  end

  def test_a_model_that_marks_nothing_is_arranged_by_nothing
    assert_nil Recourse.position_column(Place)
  end

  # The word means ascending to Active Record, which has never heard of it, and the
  # hash a host wrote is left as it wrote it.
  def test_the_marked_key_reaches_active_record_as_ascending
    assert_equal({ position: :asc }, Recourse.order_for(Team))
    assert_equal({ position: :positionable }, Team.recourse_order)
  end

  def test_an_order_that_is_not_a_hash_is_passed_straight_through
    assert_equal :id, Recourse.order_for(Place)
  end

  def test_it_refuses_a_column_the_table_has_not_got
    error = assert_raises Recourse::Error do
      arranged_by(:nowhere) { Recourse.position_column Team }
    end

    assert_includes error.message, 'no such column'
  end

  # A column no index covers is one no table can be read in the order of, which is
  # the whole of what arranging asks for.
  def test_it_refuses_a_column_no_index_covers
    error = assert_raises Recourse::Error do
      arranged_by(:uid) { Recourse.position_column Team }
    end

    assert_includes error.message, 'no database index covers it'
  end

  def test_it_refuses_two_orders_for_one_table
    error = assert_raises Recourse::Error do
      arranged_by(:position, :uid) { Recourse.position_column Team }
    end

    assert_includes error.message, 'two orders for one table'
  end

  # A flat list is arranged on its own index: nothing points away from a team, so
  # that page is the whole of what a position counts within.
  def test_a_model_nothing_nests_is_arranged_on_its_own_index
    assert Recourse.arranges?(Team, nil)
  end

  # A model reached through a parent is arranged under that parent and nowhere else.
  # Listed across every parent the positions read 1..6 ten times over, which is an
  # order of nothing.
  def test_a_nested_model_is_arranged_under_its_parent_and_not_above_it
    assert Recourse.arranges?(Memo, person_key)
    refute Recourse.arranges?(Memo, nil)
  end

  def test_a_model_that_marks_nothing_is_arranged_at_no_level_at_all
    refute Recourse.arranges?(Place, person_key)
  end

private

  # The `belongs_to` a nested memo route names, which is what makes every row on such
  # a page share one parent — and what a page drawn over an aggregate has none of.
  def person_key
    Memo.recourse_references.find { |one| one.name == :person }
  end

  # Marks the named keys `:positionable` on Team for the length of the block, so a
  # declaration the dummy would never ship can still be asked about.
  def arranged_by(*columns)
    order = columns.to_h { |column| [column, :positionable] }
    Team.define_singleton_method(:recourse_order) { order }
    yield
  ensure
    Team.singleton_class.remove_method :recourse_order
  end
end
