require 'test_helper'
require 'integration_case'

# What a page costs. Exempt from "as few tests as coverage needs": the same lines
# run whether a page issues two queries or forty, so no covered line stands in for
# either of these — and a later edit could quietly add one back.
class TestRecoursesPerformance < IntegrationCase
  def setup
    Rails.cache.clear
    # Asked once per class per process, and this counts what a *request* costs.
    # Left to chance it lands in whichever test reaches one of these menus first.
    [Team, Grade, Reading].each(&:recourse_listable?)
    super
  end

  # One count for the pagination and one select for the rows, however many rows
  # there are and however many belongs_to each names: a table showing a referenced
  # record would otherwise be a query per cell, and the eager load is what stops it.
  def test_an_index_costs_one_count_and_one_select_on_its_own_table
    queries = queries_on('places') { visit '/places' }

    assert_equal 2, queries.size
    assert_match(/COUNT/, queries.first)
    refute_match(/COUNT/, queries.last)
  end

  # What a filter costs, which no covered line says: a menu over a table past
  # MENU_LIMIT selects every row of it and renders a button each, and the same lines
  # run whether it holds four options or forty thousand. So a key pointing at such a
  # table is offered no menu — the question a form field asks of the same key, asked
  # here too — and a page that offers none reads its own rows and nothing further.
  def test_a_filter_offers_no_menu_over_a_table_too_long_to_list
    queries = queries_on('readings') { visit '/readings' }

    assert_equal 2, queries.size
    assert_match(/COUNT/, queries.first)
    refute_includes body, "data-bs-name='q[previous_reading_id_in]'"
  end

  # The column costs one query for the whole page rather than one a row, and the
  # order it imposes costs nothing at all: the kept ids are read once for the
  # squares, and the ordering rides inside the select the table was issuing anyway.
  def test_a_bookmark_column_costs_one_query_and_the_order_it_imposes_costs_none
    queries = queries_on('bookmarks') { visit '/places' }

    assert_equal 2, queries.size
    assert_match(/\ASELECT "places"/, queries.first)
    assert_match(/\ASELECT "bookmarks"."topic_id"/, queries.last)
  end

  # The menu behind a combobox is cached on the relation, so a second request reads
  # the rows again only if a row changed — and asks that in one count rather than by
  # fetching them. The count is the price of never serving a stale menu.
  def test_a_warm_combobox_checks_its_version_without_fetching_the_rows_again
    cold = queries_on('teams') { visit '/places/new' }
    warm = queries_on('teams') { visit '/places/new' }

    assert_equal 2, cold.size
    assert_match(/COUNT/, warm.sole)
  end

  # And a menu over a table Rails keeps no timestamps on is drawn every time instead of
  # kept: there is nothing to version it by. `cache` builds a key from `MAX(updated_at)`
  # without asking whether the column is there, so keeping this one would answer a 500
  # rather than a list of four words.
  def test_a_menu_with_no_timestamp_to_version_it_is_drawn_rather_than_kept
    place = Place.where.missing(:audit).order(:id).first
    cold = queries_on('grades') { visit "/places/#{place.id}/audit/new" }
    warm = queries_on('grades') { visit "/places/#{place.id}/audit/new" }

    assert_includes body, Grade.order(:name).first.name
    # Fetched both times, and never counted: a warm menu that had been kept would ask
    # for its version instead, which is what the test above measures.
    assert_equal cold, warm
    refute_match(/COUNT/, cold.sole)
  end

  # A counter cache bumps the parent's column without touching its `updated_at`, so
  # a table keyed on the relation would serve the cached figure — `touch: true`
  # beside the counter is what expires it.
  def test_a_new_child_expires_the_cached_count_on_the_parents_index
    team = Team.order(:id).first
    visit '/teams'
    # The figure links to wherever the counted rows were nested, which here is under
    # a namespace — read off the routes rather than joined onto the parent's path, and
    # unique enough on its own to find the cell by. It is the first of the count's two
    # forms, the bare one a narrow table shows, so the figure is read out of its span.
    cell = %r{href="/teams/#{team.id}/visited/places"><span[^>]*>(\d+)<}
    before = body[cell, 1].to_i
    place = team.places.create! zip: ZIP.order(:id).first, name: 'Counted', slug: 'counted',
                                capacity: 1, active: true
    visit '/teams'

    assert_equal before + 1, body[cell, 1].to_i
  ensure
    place&.destroy
  end
end
