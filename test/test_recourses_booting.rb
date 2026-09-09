require 'test_helper'

# What `recourses` does with a missing controller while an app boots without eager
# loading, as a production rake task does — drawing its routes before it is done.
class TestRecoursesBooting < Minitest::Test
  def setup
    @app = Rails.application
    def @app.initialized? = false
  end

  def teardown
    @app.singleton_class.remove_method :initialized?
  end

  def test_a_controller_drawn_while_booting_is_defined_when_the_app_first_runs
    Recourse::Controllers.define_missing 'admin/held'

    refute Object.const_defined?('Admin::HeldController')
    @app.executor.wrap { assert_operator Admin::HeldController, :<, RecoursesController }
  end
end
