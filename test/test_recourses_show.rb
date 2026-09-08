require 'test_helper'
require 'integration_case'

# A record's own page, and the card the nested indexes hang off it by.
class TestRecoursesShow < IntegrationCase
  # One pass over a record carrying a value of every kind, each read out as what its
  # column holds rather than as what the database keeps: money wears its currency
  # and a percentage its sign, both decimals underneath; a float keeps its own
  # precision; a date and a time are `time` tags a browser can localize; an enum is
  # a badge and a boolean is the word, not an icon; a URL is a link to itself.
  def test_it_reads_out_a_value_of_every_kind_in_the_shape_its_column_earns
    visit "/places/#{Place.order(:id).first.id}"

    assert_includes body, '$20.00'
    assert_includes body, '5.25%'
    assert_includes body, '100.25'
    assert_includes body, '0.500'
    assert_includes body, '415-555-0000'
    # A month is the word for one, and a year the digits it is: neither counts
    # anything, so neither wears the delimiter `capacity` beside them would.
    assert_includes body, 'February'
    assert_includes body, '1991'
    refute_includes body, '1,991'
    assert_includes body, '<time datetime="2026-01-01">Jan 1, 2026</time>'
    assert_includes body, 'datetime="2026-06-01T09:30:00-04:00"'
    assert_includes body, '<span class="badge">draft'
    # Words rather than icons, and the reference read as its label either way.
    assert_includes body, 'true'
    assert_includes body, 'false'
    assert_includes body, '90001'
    assert_includes body, 'Blue Crew'
    # A URL links to itself and reads as its host: no protocol, no trailing slash.
    assert_includes body, '<a href="https://place-1.example.com"'
    assert_includes body, '>place-1.example.com <'
    # And the payload the index leaves out: a record's own page is where a value too
    # wide for a column of them still belongs.
    assert_includes body, 'step_free_access'
    # A list is the other of those, and it reads as how many before it reads as what:
    # closed, so a column of values a reader scans is not pushed down by one of them.
    assert_includes body, '<details><summary>3 items</summary><ul class="mb-0 mt-2">' \
                          '<li>Riverside</li><li>Terrace</li><li>Wheelchair access</li></ul>'
    # A single file is a value here rather than a table of one row, and nothing
    # attached reads as the dash every other empty value reads as. A shelf of them is
    # not: `photos` has a page of its own, where a column of filenames says more.
    assert_includes body, '<div class="form-label">Floor plan</div>' \
                          '<div class="form-control-plaintext">—</div>'
    refute_includes body, '<div class="form-label">Photos</div>'
  end

  # A file a browser can draw is offered rather than only named: a `<details>` the
  # reader opens to see it where it stands, at the column's width, so a photograph
  # shrinks to fit instead of deciding the page's layout. Closed to begin with, since
  # a record's page is a column of values to scan and an open image pushes the rest of
  # them down. Clicking what it drew is the download the name alone would have
  # started — a file a browser draws nothing of stays that plain link, as `plan.txt`
  # is over in the writes.
  def test_a_file_a_browser_can_draw_opens_on_the_page_itself
    place = Place.order(:id).first
    blob = image_blob
    ActiveStorage::Attachment.create! blob:, name: 'floor_plan', record: place
    visit "/places/#{place.id}"

    assert_includes body, '<details><summary>hairy.png</summary><a target="_blank"'
    assert_includes body, 'disposition=attachment"><img src='
    assert_includes body, 'disposition=inline" alt="hairy.png" class="img-fluid mt-2">'
  ensure
    ActiveStorage::Attachment.where(blob:).destroy_all
    blob&.destroy
  end

  # The card a record's own page sits in: its Show tab first, then one tab per index
  # nested under it, in the order routes.rb nested them rather than the order the
  # associations were declared. A counter cache decides how a tab reads and never
  # whether it is there — Places carries one, Memos does not.
  def test_the_card_tabs_follow_the_routes_and_read_by_what_is_counted
    person = Person.order(:id).first
    visit "/people/#{person.id}"

    assert_includes body, %(href="/people/#{person.id}/places">)
    assert_includes body, "#{person.places_count} places"
    assert_includes body, %(href="/people/#{person.id}/memos">)
    assert_includes body, '</i> Memos</a>'
    # The tab order is the routes file's: places was nested first. By href, since a
    # bare action's button carries a path of its own before the tabs are drawn.
    assert_operator body.index(%(href="/people/#{person.id}/places")), :<,
                    body.index(%(href="/people/#{person.id}/memos"))
  end

private

  # Recorded rather than uploaded, the way the seed records the photos beside it: what
  # a page draws is the blob's own row — the name and the type — never the bytes.
  def image_blob
    ActiveStorage::Blob.create_before_direct_upload! byte_size: 12, checksum: 'hairy',
                                                     content_type: 'image/png',
                                                     filename: 'hairy.png'
  end
end
