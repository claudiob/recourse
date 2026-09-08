require 'test_helper'
require 'integration_case'

# The two writes behind the square, and what each answers.
class TestRecoursesBookmarksWrites < IntegrationCase
  KEPT = 4

  def teardown
    Bookmark.where.not(topic_id: [KEPT, 7]).destroy_all
    Bookmark.find_or_create_by! person: Person.order(:id).first, topic: Place.find(KEPT)
  end

  # The viewer comes from the host's own declaration rather than from the form, so
  # `create` writes a row nobody submitted a person for.
  def test_create_keeps_the_row_for_whoever_is_looking_and_says_so
    @session.post '/places/1/bookmark'

    assert_equal 303, @session.response.status
    bookmark = Bookmark.find_by! topic: Place.find(1)

    assert_equal Person.order(:id).first, bookmark.person
    follow_and_assert_flash 'Bookmark added'
  end

  def test_destroy_drops_it_and_warns
    @session.delete "/places/#{KEPT}/bookmark"

    assert_equal 303, @session.response.status
    assert_empty Bookmark.where(topic: Place.find(KEPT))
    follow_and_assert_flash 'Bookmark removed'
  end

  # The background request the square actually makes: nothing to render, and — the
  # point of the branch — no flash left in the session to surface as a toast on
  # whatever page is loaded next.
  def test_a_background_request_is_answered_with_nothing_at_all
    @session.post '/places/1/bookmark', headers: background

    assert_equal 204, @session.response.status
    assert_empty @session.response.body
    visit '/places'
    refute_includes body, 'class="toast fade show'
  end

  # Twice kept is once kept: the square answers before the request does, so a second
  # click can arrive while the first is still in flight.
  def test_keeping_a_row_twice_keeps_it_once
    2.times { @session.post '/places/1/bookmark' }

    assert_equal 1, Bookmark.where(topic: Place.find(1)).count
  end

  # The square flips the verb its form was drawn with, and Rails scopes a form's own
  # token to that verb — so the token `button_to` wrote stops matching on the first
  # click. The one in the head does not: it is global to the session. Forgery
  # protection is off for the rest of the suite, which is why this turns it on rather
  # than assuming the request that shipped was ever checked.
  def test_the_square_is_written_with_the_token_from_the_head
    with_forgery_protection do
      visit '/places'
      token = body[/<meta name="csrf-token" content="([^"]+)"/, 1]
      @session.post '/places/1/bookmark', headers: background.merge('X-CSRF-Token' => token)

      assert_equal 204, @session.response.status
    end
  end

  # No square is drawn for a model that keeps none, so the only way here is by hand.
  def test_a_resource_that_keeps_none_is_not_there
    assert_raises(ActiveRecord::RecordNotFound) { @session.post '/teams/1/bookmark' }
  end

private

  def background
    { 'ACCEPT' => 'application/json' }
  end

  def with_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = false
  end
end
