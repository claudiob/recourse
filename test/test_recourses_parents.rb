require 'test_helper'
require 'integration_case'

# The record a nested route sits under, named the way a hand-written controller would
# name it -- so a host's own row or form reads `@person` with no scoping concern of its
# own to write. The same contract the gem already keeps for the record a page is about.
class TestRecoursesParents < IntegrationCase
  # The ordinary nesting, where a key joins the two. The parent is already resolved to
  # scope the rows, so the name goes on the record that was found rather than on one
  # looked up a second time.
  def test_a_nested_page_names_the_record_its_path_sits_under
    person = Person.order(:id).find { |one| one.places.any? }
    visit "/people/#{person.id}/places"

    assert_equal person, @session.controller.view_assigns['person']
  end

  # And the nesting no key joins. A memo belongs to a person and never to a team, so
  # nothing about the models says which team `/teams/5/memos` is under -- only the path
  # does. Which is why the name is read off the route rather than off an association,
  # and this is the case a host could reach no other way.
  def test_a_page_nested_by_the_path_alone_names_its_record_too
    team = Team.order(:id).second
    visit "/teams/#{team.id}/memos"

    assert_nil Memo.reflect_on_association(:team)
    assert_equal team, @session.controller.view_assigns['team']
  end
end
