require 'test_helper'
require 'integration_case'

# A page a host says is the same for everybody. Exempt from "as few tests as coverage
# needs": each of these pins what a shared cache would otherwise get wrong — one reader's
# zone, size, density or token on the next reader's page.
class TestRecoursesPublicPages < IntegrationCase
  # The dummy app turns forgery protection off in test, which draws no token and so would
  # let a page with none pass for one that took it out.
  def setup
    super
    @forgery = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  def teardown
    ActionController::Base.allow_forgery_protection = @forgery
    Recourse.public_pages = nil
    Recourse.public_version = nil
    Recourse.public_cache = nil
  end

  def test_a_host_that_says_nothing_keeps_every_page_private_to_its_reader
    visit '/zips'

    refute_includes @session.response.headers['Cache-Control'], 'public'
    assert_includes body, 'name="csrf-token"'
  end

  def test_a_page_the_host_calls_public_is_sent_for_everybody_to_keep
    Recourse.public_pages = -> { true }
    visit '/zips'

    control = @session.response.headers['Cache-Control']

    assert_includes control, 'public'
    assert_includes control, 'max-age=300'
    assert_includes control, 's-maxage=86400'
    assert_includes control, 'stale-while-revalidate=86400'
    assert_includes control, 'stale-if-error=604800'
    assert_includes @session.response.headers['Vary'], 'Turbo-Frame'
    refute_includes body, 'name="csrf-token"'
    refute_includes body, 'action="/session"'
    assert_nil @session.response.headers['Set-Cookie']
  end

  def test_a_host_sets_how_long_each_keeper_keeps_it
    Recourse.public_pages = -> { true }
    Recourse.public_cache = { shared_max_age: 60 }
    visit '/zips'

    assert_includes @session.response.headers['Cache-Control'], 's-maxage=60'
    assert_includes @session.response.headers['Cache-Control'], 'max-age=300'
  end

  def test_the_host_is_asked_in_the_controller_so_it_can_tell_who_is_reading
    Recourse.public_pages = -> { request.path != '/zips' }
    visit '/zips'

    refute_includes @session.response.headers['Cache-Control'], 'public'
  end

  def test_what_the_reader_told_the_server_is_not_in_a_page_everybody_is_shown
    Recourse.public_pages = -> { true }
    @session.cookies[Recourse::LIMIT_STORAGE] = '100'
    @session.cookies[Recourse::DENSITY_STORAGE] = 'expanded'
    visit '/zips'

    assert_includes body, 'Displaying items 1-15 of 201'
    assert_includes body, "<body class='recourse-shell'"
    assert_includes body, "document.body.classList.add('recourse-expanded')"

    place = Place.order(:id).first
    @session.cookies[Recourse::ZONE_STORAGE] = 'Asia/Tokyo'
    visit "/places/#{place.id}"

    refute_includes body, 'JST</time>'
  end

  def test_a_frame_is_never_public_since_the_same_address_answers_a_page
    Recourse.public_pages = -> { true }
    @session.get '/zips', headers: { 'Turbo-Frame' => 'results' }

    refute_includes @session.response.headers['Cache-Control'], 'public'
  end

  def test_a_page_that_still_stands_is_answered_with_no_body
    Recourse.public_pages = -> { true }
    Recourse.public_version = -> { ['imported', 1] }
    visit '/zips'
    etag = @session.response.headers['ETag']

    @session.get '/zips', headers: { 'If-None-Match' => etag }

    assert_equal 304, @session.response.status
    Recourse.public_version = -> { ['imported', 2] }
    @session.get '/zips', headers: { 'If-None-Match' => etag }

    assert_equal 200, @session.response.status
  end
end
