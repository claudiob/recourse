require 'test_helper'
require 'integration_case'

# An action the routes drew under a record with no page of its own to reach it
# from, and the button the gem puts on the record instead.
class TestRecoursesActions < IntegrationCase
  # This suite runs against a database that keeps whatever a test wrote, so what
  # these tests write they also take back.
  def teardown
    Memo.where(body: [nil, 'Noted']).destroy_all
  end

  # A nested resource routed `create` with no page of its own is reached from nowhere,
  # so the gem puts its button on the record's own page, on that page alone -- and with
  # no index to return to, lands the write back on the very page it stood on.
  def test_a_nested_action_with_no_page_gets_a_button_on_its_parent
    person = Person.order(:id).first
    visit "/people/#{person.id}"

    assert_includes body, %(action="/people/#{person.id}/quick/memos")
    # Led by the namespace the routes put between the person and the action: without
    # it this button and the `memos` index's own Add would read the same words.
    assert_includes body, 'Add quick memo'

    visit "/people/#{person.id}/places"

    refute_includes body, 'Add quick memo'
    @session.post "/people/#{person.id}/quick/memos"

    assert_equal 303, @session.response.status
    assert_equal "http://localhost/people/#{person.id}", @session.response.location
    assert_nil person.memos.order(:id).last.body
  end

  # And a name this app has no class for at all. An action is a verb, so most of
  # them are: the button takes the word the route used, and posting it is answered
  # like any other — the questions the gem asks of every request are asked of the
  # model behind the page, and this page has none to ask them of.
  def test_a_bare_action_needs_no_model_behind_it
    place = Place.order(:id).first
    visit "/places/#{place.id}"

    assert_includes body, %(action="/places/#{place.id}/sweeps")
    assert_includes body, 'Add sweep'

    @session.post "/places/#{place.id}/sweeps"

    assert_equal 303, @session.response.status
    assert_equal "Swept #{place.name}", @session.request.flash[:notice]
  end

  # A route named `exit` is how the routes declare the way out: a button beside the toggle.
  def test_a_route_named_exit_earns_the_sidebar_a_way_out
    visit '/people'

    assert_includes body,
                    %(<form data-turbo="false" class="button_to" method="post" action="/session">)
    assert_includes body, %(<input type="hidden" name="_method" value="delete")
    assert_includes body, "<i class='bi bi-box-arrow-right'></i>"
    assert_includes body, '>Log out</span>'
  end
end
