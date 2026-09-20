require 'test_helper'
require 'integration_case'

# What the routes file may and may not nest inside what, and the one action a nesting
# earns with no page of its own.
class TestRecoursesNestingRoutes < IntegrationCase
  def teardown
    Memo.where(body: nil).destroy_all
  end

  # What is refused is a nesting that adds no namespace at all: only a `recourses`
  # block gives a nested controller a namespace of its own, and without one the
  # nested `PlacesController` and the top-level one would be a single class. It
  # fails while the routes draw rather than answering a broken page later.
  def test_it_refuses_recourses_nested_inside_plain_resources
    error = assert_raises Recourse::Error do
      ActionDispatch::Routing::RouteSet.new.draw do
        resources :people, only: :index do
          recourses :places, only: :index
        end
      end
    end

    assert_includes error.message, 'Nest it under `recourses :people` instead.'
  end

  # A nested resource routed `create` without `new` offers a one-click Create in the
  # Add link's place: it posts the record whole and comes back to the index holding
  # it. Our word, in the routes file, that a bare memo can stand.
  def test_a_bare_create_posts_the_record_whole_from_the_index
    person = Person.order(:id).first
    visit "/people/#{person.id}/memos"

    assert_includes body, %(action="/people/#{person.id}/memos")
    assert_includes body, 'Create'
    refute_includes body, %(href="/people/#{person.id}/memos/new")
    @session.post "/people/#{person.id}/memos"

    assert_equal 303, @session.response.status
    assert_equal person, Memo.find_by!(body: nil).person
  end
end
