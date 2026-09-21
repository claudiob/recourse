require 'test_helper'
require 'integration_case'

# A table whose rows came from somewhere else, and the button that fetches them again.
class TestRecoursesRetrievals < IntegrationCase
  # The routes say the rows may be fetched again, so the table that lists them carries
  # the button that asks — and the route it posts to is drawn under the resource, on
  # the collection rather than on any one row.
  def test_a_retrievable_index_carries_the_button_that_fetches_its_rows
    visit '/places'

    assert_includes body, 'action="/places/retrieval"'
    assert_includes body, 'aria-label="Retrieve places again"'
    @session.post '/places/retrieval'

    assert_equal 303, @session.response.status
    follow_and_assert_flash 'Fetching places'
  end

  # And the host says when there is nothing to fetch from: a page that cannot answer
  # for where its rows came from offers nothing rather than a button that fails.
  def test_a_host_that_says_it_cannot_be_retrieved_is_offered_no_button
    Admin::PlacesController.define_method(:recourse_retrievable?) { false }
    visit '/places'

    refute_includes body, 'action="/places/retrieval"'
  ensure
    Admin::PlacesController.send :remove_method, :recourse_retrievable?
  end

  # The button stands on the table that lists the rows, so a resource asking to be
  # retrievable without an index has nowhere to put it.
  def test_it_refuses_a_retrievable_resource_with_no_index
    error = assert_raises Recourse::Error do
      ActionDispatch::Routing::RouteSet.new.draw do
        recourses :places, only: :show, retrievable: true
      end
    end

    assert_includes error.message, 'nowhere to put it'
  end
end
