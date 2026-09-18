require 'test_helper'

# Which picture a name is drawn with, where the name is a route's rather than a model's.
class TestRecoursesIcons < Minitest::Test
  def test_a_name_naming_a_drawn_model_draws_what_that_model_names
    assert_equal Unicon[Place.recourse_icon][:bootstrap], Recourse.known_icon('admin/places')
  end

  # A word this app has no class for at all: a bare action is drawn under one, and an
  # icon is not worth raising over.
  def test_a_name_naming_no_class_draws_nothing
    assert_nil Recourse.known_icon('admin/places/sweeps')
  end

  # And a word that does resolve, to something that was never a table: a crumb over a
  # host's own gathering class would have asked it a hook it never heard of.
  def test_a_name_naming_a_class_that_is_not_a_drawn_model_draws_nothing
    assert_nil Recourse.known_icon('admin/people/rollups')
  end
end
