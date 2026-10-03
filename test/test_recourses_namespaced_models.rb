require 'test_helper'
require 'integration_case'

# A model kept in a module, found by a route drawn in that module: `admin/badges` lists
# an Admin::Badge, and every route without one in its module lists the top-level class.
class TestRecoursesNamespacedModels < IntegrationCase
  def setup
    super
    @person = Person.create! name: 'Kip', email: 'kip@example.com'
    @badge = @person.badges.create! name: 'First aid'
  end

  def teardown
    Person.where(name: 'Kip').destroy_all
  end

  def test_a_route_in_a_module_lists_the_model_kept_in_that_module
    assert_equal Admin::Badge, Recourse.model('admin/badges')
  end

  # Nested under a parent, the path gains the parent's segment, where no model lives:
  # the module the route was drawn in is looked in next.
  def test_a_nested_route_looks_in_the_module_around_its_parent
    assert_equal Admin::Badge, Recourse.model('admin/people/badges')
  end

  # What every route answered before a model could be kept in a module.
  def test_a_route_whose_module_keeps_no_such_model_lists_the_top_level_one
    assert_equal Place, Recourse.model('admin/places')
    assert_equal Memo, Recourse.model('admin/people/memos')
  end

  # Admin::Place is not there, but a module looks up its constants in Object too, which
  # would have answered with a top-level class the module never kept.
  def test_a_class_outside_the_module_is_never_taken_for_one_inside_it
    assert_nil Recourse.send(:namespaced_model, 'admin/places')
  end

  # A host's own class in the module is not a table, and never takes a page over.
  def test_only_an_active_record_model_in_the_module_counts
    assert_nil Recourse.send(:namespaced_model, 'recourse/errors')
  end

  def test_the_routes_ask_whether_the_model_is_there_without_loading_it
    assert Recourse.model_defined?('admin/badges')
    assert Recourse.model_defined?('admin/places')
    refute Recourse.model_defined?('admin/sweeps')
  end

  def test_the_index_and_the_record_of_a_namespaced_model_are_drawn
    visit '/badges'

    assert_includes body, 'First aid'
    assert_includes body, %(href="/badges/#{@badge.id}")

    visit "/badges/#{@badge.id}"

    assert_includes body, 'First aid'
  end

  def test_the_nested_index_of_a_namespaced_model_lists_the_parents_rows
    other = Person.create!(name: 'Kip', email: 'kip2@example.com').badges.create! name: 'Lifeguard'
    visit "/people/#{@person.id}/badges"

    assert_includes body, 'First aid'
    refute_includes body, other.name
  end

  # The route's name for the model, `badge`, rather than the model's own `admin_badge`:
  # the path a square posts to and the id a nested page reads its parent by.
  def test_a_namespaced_model_is_kept_and_nested_under_by_its_route_name
    visit '/badges'

    assert_includes body, %(action="/badges/#{@badge.id}/bookmark")

    visit "/badges/#{@badge.id}/memos"

    assert_includes body, 'First aid'
  end
end
