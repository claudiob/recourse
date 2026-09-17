require 'test_helper'
require 'integration_case'

# A table whose rows say when they open and when they close can be read as a week of
# them, the way a table of places can be read as a map.
class TestRecoursesCalendars < IntegrationCase
  # The footer offers the calendar where there is one to offer, and the calendar the
  # table back. Exempt from "as few tests as coverage needs" for the reason the map's
  # link is: the same lines run whichever address the link carries.
  def test_a_table_of_events_and_its_calendar_each_lead_to_the_other
    visit '/shifts'

    assert_includes body, %(href="/shifts.cal">Display as calendar</a>)
    refute_includes body, 'Display as table'

    visit '/shifts.cal'

    assert_includes body, %(href="/shifts">Display as table</a>)
    refute_includes body, '<table'

    # A team opens and closes nothing, so its table is the only shape it has.
    visit '/teams'

    refute_includes body, 'Display as'
  end

  # One week: a column a day under its own heading, the hours the week's own rows run
  # between down the side, and each row placed by the share of the grid it takes — two
  # that overlap in lanes of their own, and the day's third alongside them.
  def test_the_week_draws_a_column_a_day_and_lays_the_rows_that_overlap_side_by_side
    day = crowded_day
    week = Recourse.week_of day

    visit "/shifts.cal?week=#{week}"

    (week..(week + 6)).each do |one|
      assert_includes body, ">#{I18n.l one, format: :recourse_day}</span>"
    end
    # The scale runs from the hour the earliest row opens in, and no earlier, over a
    # grid as tall as a table's own first page — so both shapes carry their footer at
    # one height.
    assert_includes body, '>9am</div>'
    refute_includes body, '>8am</div>'
    assert_includes body, 'height: calc(15 * (1em * var(--bs-body-line-height)'
    # The last of the three: half the width, the second half of it, and starting three
    # quarters of the way down a grid that runs 9am to 5pm.
    handover = Shift.where(starts_at: day.in_time_zone + 15.hours).sole

    assert_includes body, 'style="top: 75.0%; height: 25.0%; left: 50.0%; width: 50.0%"'
    assert_includes body, %(href="/shifts/#{handover.id}">Handover</a>)
    # And whose it is under its name, led to that record's own page like any cell.
    assert_includes body, %(href="/people/#{handover.person_id}">#{handover.person.name}</a>)
    assert_includes body, %(<time datetime="#{handover.starts_at.rfc3339}">3:00pm</time>)
    assert_includes body, %(–<time datetime="#{handover.ends_at.rfc3339}">5:00pm</time>)
  end

  # With nothing in the address the calendar is the reader's own week, and with a day
  # in it nothing can be made of it is that week again — an address is a stranger's to
  # write, so a forged one is answered rather than raised on.
  def test_the_calendar_opens_on_this_week_and_on_this_week_again_for_an_address_it_cannot_read
    week = Recourse.week_of Time.zone.today
    named = "#{week.strftime '%B'} #{week.day.ordinalize} – "

    ['/shifts.cal', '/shifts.cal?week=whenever'].each do |path|
      visit path

      # The week showing is named where pagy names the page, and left unlinked the way
      # pagy leaves it: a page offers no address for the page it is already on.
      assert_includes body, %(aria-current="page" aria-disabled="true">#{named})
    end
  end

  # A week nothing happens in still draws the grid, or there would be nothing on the
  # page to reach the weeks either side by — and it draws a working day, there being no
  # rows to take the hours from.
  def test_a_week_with_nothing_in_it_still_draws_the_grid_and_the_weeks_either_side
    visit '/shifts.cal?week=2020-01-08'

    assert_includes body, 'January 5th – January 11th, 2020'
    assert_includes body, 'Displaying 0 items'
    assert_includes body, '>8am</div>'
    assert_includes body, %(aria-label="Previous week" href="/shifts.cal?week=2019-12-29">&lt;</a>)
    assert_includes body, %(aria-label="Next week" href="/shifts.cal?week=2020-01-12">&gt;</a>)
    refute_includes body, 'position-absolute'
  end

private

  # The day the migration gave a third shift to, which is the one whose rows overlap.
  # Read off the rows rather than named here: they are written around the day this
  # app's database was made, so no date in a test could name one.
  def crowded_day
    Shift.pluck(:starts_at).map(&:to_date).tally.max_by(&:last).first
  end
end
