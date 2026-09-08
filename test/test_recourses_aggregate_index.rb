require 'test_helper'
require 'integration_case'

# The page a resource with no rows of its own draws. `Week` counts the memos of this app
# by the week they were written in, and its controller says only what those rows are:
# the table around them, the paging under it and the chrome outside are the gem's.
class TestRecoursesAggregateIndex < IntegrationCase
  # Such a page is drawn like any other, through the gem's own table: the cells are
  # this app's, there being no columns to lay a table out from, and the headings, the
  # paging and the chrome are the gem's.
  def test_an_aggregate_index_is_drawn_like_any_other
    weeks = Week.all
    visit '/weeks'

    assert_includes body, %(<td data-cell="Week">#{weeks.first}</td>)
    assert_includes body, %(<td data-cell="Memos">#{weeks.first.memos}</td>)
    assert_includes body, '<title>Weeks</title>'
    assert_includes body, 'recourse-sidebar'
  end

  # And with no square to keep a row by, though this app keeps bookmarks and every other
  # table here opens with one. A bookmark is found along a model's own `has_many`, and an
  # aggregate answers that with the nothing it has — which is the question that reaches
  # furthest past keys, and the one a table asks before drawing its first column.
  def test_an_aggregate_index_offers_no_way_to_keep_a_row
    visit '/places'
    assert_includes body, 'data-cell="Bookmark"'

    visit '/weeks'

    refute_includes body, 'data-cell="Bookmark"'
    # Nor a name of its own, for the same reason: `to_key` is nil for every one of
    # these, and a row named from that is `new_week` twenty times over — one name for
    # twenty rows, which is worse than none. A record's row is named `place_4`.
    refute_includes body, '<tr id='
  end

  # Paging is the one thing left of what an index does to a collection, and it is done:
  # a page holds what every page holds and the next one carries on where it left off.
  #
  # Which is also what holds the table to being drawn afresh each time. These rows are
  # plain objects: `to_param` is nil for every one of them, so a kept fragment would file
  # both pages under the same key and serve the first of them twice.
  def test_an_aggregate_index_is_paged_like_any_other
    weeks = Week.all
    assert_operator weeks.size, :>, Recourse::LIMITS.first
    assert_nil weeks.first.to_param

    visit '/weeks'
    assert_equal Recourse::LIMITS.first, rows
    assert_includes body, weeks.first.to_s
    refute_includes body, weeks.last.to_s

    visit '/weeks?page=2'
    assert_equal weeks.size - Recourse::LIMITS.first, rows
    assert_includes body, weeks.last.to_s
    refute_includes body, weeks.first.to_s
  end

  # And drawn afresh each time, which is what rows being plain objects cost. A record
  # says when it last changed and a kept fragment is filed under that; an object built
  # in Ruby says nothing — `to_param` is nil for every week here — so a kept table would
  # serve the next reader of any such page this one. Proved by moving a figure without
  # moving a row: the memo is dated into the newest week, since today may have begun a
  # week no memo is in — a new row, whose figure would say nothing about a kept table.
  def test_an_aggregate_index_is_never_kept
    visit '/weeks'
    counted = memos_of_the_newest_week

    Memo.create! body: 'Written this week', person: Person.order(:id).first,
                 created_at: Memo.maximum(:created_at)
    visit '/weeks'

    assert_equal counted + 1, memos_of_the_newest_week
  ensure
    Memo.where(body: 'Written this week').destroy_all
  end

  # Nothing to search it by and nothing to sort it by, which is what leaves the page
  # without a box above it and without a link in any heading. Against an ordinary index
  # in the same breath, so the absence is read as this page's rather than as a query
  # string the layout never carries anyway.
  def test_an_aggregate_index_offers_no_search_and_no_sort
    visit '/memos'
    assert_includes body, 'q%5B'

    visit '/weeks'

    refute_includes body, 'q%5B'
    refute_includes body, 'name="q['
  end

private

  # How many rows the page drew, each cell naming the column it stands under.
  def rows = body.scan('<td data-cell="Week">').size

  # And what the first of them counts, the weeks reading newest first.
  def memos_of_the_newest_week = body[/data-cell="Memos">(\d+)</, 1].to_i
end
