require 'test_helper'
require 'integration_case'

# What `update` does with a change that saves, and with one that will not.
class TestRecoursesUpdates < IntegrationCase
  def test_update_saves_and_says_so
    team = Team.order(:id).first
    @session.patch "/teams/#{team.id}", params: { team: { name: 'Blue Crew' } }

    assert_equal 303, @session.response.status
    follow_and_assert_flash 'Team was updated.'
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
