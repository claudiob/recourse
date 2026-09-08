require 'test_helper'
require 'integration_case'

# How much of a table one page shows, and the reader's own say in it.
class TestRecoursesPagination < IntegrationCase
  # Twenty to a page, the count delimited, and the nav only where there is a second
  # page to reach. Exempt from "as few tests as coverage needs": the same lines run
  # whether the figures are right or wrong.
  def test_it_paginates_at_twenty_rows_and_says_what_it_is_showing
    visit '/zips'

    assert_includes body, 'Displaying items 1-20 of 101 in total'
    assert_includes body, 'href="/zips?page=2"'
    # Four teams fit on one page, so that page says so and offers no nav.
    visit '/teams'

    assert_includes body, 'Displaying 4 items'
    refute_includes body, 'pagination'
    # And nothing to ask about a table that is not being paginated.
    refute_includes body, 'per page'
  end

  # The size a reader picked, kept in their browser and honoured everywhere — and
  # refused where it is not one of ours. Exempt from "as few tests as coverage needs"
  # for the same reason as the one above, and more sharply: the cookie is checked on
  # one line that runs whether it holds a size we offer or a size somebody forged.
  def test_it_shows_the_page_size_a_reader_chose_and_refuses_one_it_never_offered
    visit '/zips'

    # The button names the size it is not showing, which is where a click goes.
    assert_includes body, "<span class='fg-2'>&middot;</span>"
    assert_includes body, 'data-limit-to-value="100"'
    assert_includes body, '>100 per page</button>'

    @session.cookies[Recourse::LIMIT_STORAGE] = '100'
    visit '/zips'

    assert_includes body, 'Displaying items 1-100 of 101 in total'
    assert_includes body, 'data-limit-to-value="20"'
    assert_includes body, '>20 per page</button>'
    # A cookie is a value a stranger can write, so one naming no size we offer is not
    # a size at all — the table goes back to twenty rather than to whatever was asked.
    @session.cookies[Recourse::LIMIT_STORAGE] = '250'
    visit '/zips'

    assert_includes body, 'Displaying items 1-20 of 101 in total'
  end
end
