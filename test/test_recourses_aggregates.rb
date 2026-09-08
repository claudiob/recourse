require 'test_helper'
require 'integration_case'

# A resource with no rows of its own, which a host writes when a page is assembled out
# of other models' records rather than read off a table.
class Rollup
  include Recourse::Aggregate
end

# And one that says what it is called, which is the only thing an aggregate has to.
class Weekly
  include Recourse::Aggregate

  class << self
    def recourse_label = :headline
    def recourse_icon = :message
  end
end

class TestRecoursesAggregates < IntegrationCase
  # Including it is enough: a class with no table can still be titled, which is what
  # every crumb, tab and heading reads a resource's word from.
  def test_an_aggregate_can_be_named
    assert_equal 'Rollup', Rollup.model_name.human
    assert_equal :rollup, Rollup.recourse_icon
    assert_equal :name, Rollup.recourse_label
  end

  # Everything a table answers from its columns and its keys is answered as the nothing
  # an aggregate has, so the gem asks the same questions of both and neither raises.
  def test_an_aggregate_answers_what_a_table_reads_off_its_columns
    assert_empty Rollup.column_names
    assert_empty Rollup.recourse_hidden
    assert_empty Rollup.recourse_displayed
    assert_empty Rollup.recourse_counters
    assert_empty Rollup.recourse_references
    assert_empty Rollup.recourse_reference_types
  end

  # The two a host has reason to say for itself are the two it can.
  def test_an_aggregate_may_say_what_it_is_called_and_drawn_with
    assert_equal :headline, Weekly.recourse_label
    assert_equal :message, Weekly.recourse_icon
  end
end
