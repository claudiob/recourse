require 'test_helper'
require 'integration_case'

# A resource reached through another: what its page lists, what it asks for, and
# what the routes file may and may not put between the two.
class TestRecoursesNesting < IntegrationCase
  def teardown
    Memo.where(body: nil).destroy_all
  end

  # A nested index lists the parent record's own rows and nothing else — no column
  # for the parent, since the address already answered it, and no filter offering
  # to ask again. The crumbs read the parent's index, then the record, then here.
  def test_a_nested_index_is_the_parent_records_own_rows
    person = Person.order(:id).first
    visit "/people/#{person.id}/places"

    crumb = %(<a class="breadcrumb-link" href="/people/#{person.id}">#{person.name}</a>)

    assert_includes body, crumb
    refute_includes body, 'data-cell="Person"'
    refute_includes body, "data-bs-name='q[person_id_in]'"
    assert_equal person.places_count, body.scan('data-cell="Name"').size
  end

  # Reached through a parent, a resource that names no actions of its own answers
  # the collection ones: list the parent's rows, and add one. The form it draws
  # never asks which parent, because the path already said.
  def test_a_nested_resource_defaults_to_its_collection_actions
    zip = ZIP.order(:code).first
    visit "/zips/#{zip.id}/places/new"

    refute_includes body, 'name="place[zip_id]"'
    assert_includes body, %(action="/zips/#{zip.id}/places")
    # And the member actions stay with the resource's own routes: the row's pencil
    # points at /places/1/edit, not at one nested under this ZIP.
    visit "/zips/#{zip.id}/places"

    assert_includes body, %(href="/places/#{zip.places.order(:id).first.id}/edit")
  end

  # A `namespace` may sit between a block and what it nests: the routes, the
  # controller and the crumbs all come out under it. The middle crumb is read out
  # rather than linked here, because teams are never shown.
  def test_a_namespace_may_sit_between_a_parent_and_its_child
    team = Team.order(:id).first
    visit "/teams/#{team.id}/visited/places"

    assert_includes body, %(<a class="breadcrumb-link gap-2" href="/teams">)
    assert_includes body, %(<span class='breadcrumb-link'>#{team.name}</span>)
    assert_equal team.places_count, body.scan('data-cell="Name"').size
    # And the card is the parent's, tabs and all: no Show, since teams are never
    # shown, then this page's own tab carrying the count and marked current.
    assert_includes body, %(href="/teams/#{team.id}/edit")
    # The namespace leads the tab, so two nestings of one model read apart — and
    # it is the routes that say so, not the model, which knows nothing of either.
    assert_includes body, %(#{team.places_count} visited places)
    assert_includes body, %(active" aria-current="page" href="/teams/#{team.id}/visited/places")
    # And the tab beside it, for a nested index no `has_many` on Team answers to:
    # named after the route, with no count and no icon, because nothing else knows.
    assert_includes body, %(href="/teams/#{team.id}/memos">Memos</a>)
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
