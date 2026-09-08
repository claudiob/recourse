require 'test_helper'
require 'integration_case'

# The square a table opens with, and the two writes behind it.
class TestRecoursesBookmarks < IntegrationCase
  KEPT = 4

  def teardown
    Bookmark.where.not(topic_id: [KEPT, 7]).destroy_all
    Bookmark.find_or_create_by! person: Person.order(:id).first, topic: Place.find(KEPT)
  end

  # One pass over a table that has both: the kept row filled and asking to be
  # dropped, the unkept one hollow and asking to be kept, both at the same path with
  # only the verb between them — and the kept rows leading, which is the order a
  # model's own `recourse_order` gives way to.
  def test_the_column_draws_both_states_and_leads_with_what_is_kept
    visit '/places'

    assert_includes body, '<i class="bi bi-bookmark-fill" aria-label="Remove bookmark">'
    assert_includes body, '<i class="bi bi-bookmark" aria-label="Bookmark">'
    assert_includes body, '<input type="hidden" name="_method" value="delete" />'
    assert_includes body, %(action="/places/#{KEPT}/bookmark")
    # The row wears it too, not only the square in it: a page of twenty is scanned by
    # the tint long before anybody reads a column of icons. And it answers to a name of
    # its own, which is how a write that has just landed finds the row it landed on.
    assert_includes body, %(<tr id="place_#{KEPT}" class="recourse-kept">)
    assert_equal %w[4 7 1], body.scan(%r{/places/(\d+)/edit}).flatten.first(3)
  end

  # What the Stimulus controller reads off the button, asserted from here because a
  # typo in one of these fails silently in a browser and nowhere else.
  def test_the_square_carries_what_the_browser_needs_to_flip_it
    visit '/places'

    assert_includes body, 'data-controller="bookmark"'
    assert_includes body, 'aria-pressed="true"'
    # The one word the browser cannot look up, and only the one: a click that worked is
    # reported by the row taking color, so a failure is all there is left to say.
    assert_includes body, 'data-bookmark-error-value="Bookmark could not be saved."'
    refute_includes body, 'data-bookmark-messages-value'
    # No tooltip on a square that repeats down every row, unlike every other icon
    # here — so the only one left saying `Bookmark` is the heading above them, which
    # is icon-only and keeps one like every other icon heading.
    refute_includes body, 'data-bs-title="Remove bookmark"'
    assert_equal 1, body.scan('data-bs-title="Bookmark"').size
  end

  # A model that declares no bookmarks has not opted in, so its table opens where it
  # always did rather than on a column nobody can fill.
  def test_a_model_that_keeps_none_gets_no_column
    visit '/teams'

    refute_includes body, 'bi-bookmark'
    refute_includes body, 'data-cell="Bookmark"'
    # And no row is tinted, which is the branch that would otherwise ask a model with
    # no bookmarks for the ids of the ones it keeps. The attribute rather than the bare
    # word: the rule that colors it is in the layout of every page, tinted rows or not.
    refute_includes body, 'class="recourse-kept"'
  end
end
