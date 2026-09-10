require 'test_helper'
require 'integration_case'

# What `update` does with a change that saves, and with one that will not.
class TestRecoursesUpdates < IntegrationCase
  def test_update_saves_and_says_so
    team = Team.order(:id).first
    @session.patch "/teams/#{team.id}", params: { team: { name: 'Blue Crew' } }

    assert_equal 303, @session.response.status
    # Named by its label, and as words alone: the routes drew no `show` for teams, so
    # there is no page for the name to lead to.
    follow_and_assert_flash 'Blue Crew was updated.'
    refute_includes body, '>Blue Crew</a> was updated.'
  end

  # And a rejected change redraws the form the same way `create` does, rather than
  # redirecting to an index that would show the old value as though nothing failed.
  def test_a_rejected_change_redraws_the_form
    team = Team.order(:id).first
    @session.patch "/teams/#{team.id}", params: { team: { name: '' } }

    assert_equal 422, @session.response.status
    assert_includes body, 'is-invalid'
    assert_equal 'Blue Crew', team.reload.name
  end
end
