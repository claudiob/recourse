require 'test_helper'
require 'integration_case'

# A table of what a record has attached rather than of a model this app wrote:
# `has_many_attached :photos` and `recourses :photos, only: :index` under the same
# record, and Rails has already generated everything between the two.
class TestRecoursesAttachments < IntegrationCase
  def test_a_table_may_list_what_a_record_has_attached
    place = Place.order(:id).first
    visit "/places/#{place.id}/photos"

    # Named after what the record calls them, never after Active Storage's own word.
    assert_includes body, '<title>Photos'
    assert_equal place.photos.count, body.scan('data-cell="Filename"').size
    assert_includes body, 'data-cell="Content type"'
    # What the service keeps rather than what the reader reads: where the file sits,
    # what it hashes to, and whatever the analyzer wrote down.
    refute_includes body, 'data-cell="Key"'
    refute_includes body, 'data-cell="Checksum"'
    refute_includes body, 'data-cell="Metadata"'
  end

  # The one column naming a file is the way to open it, in a tab of its own: an
  # admin reading a page is not asking to leave it.
  def test_a_filename_links_to_the_file
    place = Place.order(:id).first
    visit "/places/#{place.id}/photos"
    link = body[%r{<a[^>]*active_storage[^>]*>[^<]*</a>}]

    assert_includes link, 'disposition=attachment'
    assert_includes link, 'target="_blank"'
    # Newest first, which is the order somebody looking at what was attached wants.
    assert_includes link, place.photos_blobs.order(created_at: :desc).first.filename.to_s
  end

  # And the page sits in the record's card like any other nested index, though no
  # key on either side says the two are related.
  def test_an_attachment_page_is_the_records_own
    place = Place.order(:id).first
    visit "/places/#{place.id}/photos"

    assert_includes body, %(href="/places/#{place.id}")
  end
end
