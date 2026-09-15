require 'test_helper'
require 'integration_case'

# A table of what a record has attached rather than of a model this app wrote:
# `has_many_attached :photos` and `recourses :photos, only: %i[index destroy]` under
# the same record, and Rails has already generated everything between the two.
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
    # And the page sits in the record's card like any other nested index, though no
    # key on either side says the two are related.
    assert_includes body, %(href="/places/#{place.id}")
  end

  # A file a browser can be shown is a picture first — WebP where the browser takes it,
  # the file's own kind where not, at half the pixels it was made with — in the link
  # that opens the whole file inline; a file nothing can draw is its
  # name and that link. Newest first, which is the order somebody looking at what was
  # attached wants.
  def test_a_file_is_a_picture_where_one_can_be_made_and_a_link_either_way
    place = Place.order(:id).first
    visit "/places/#{place.id}/photos"
    rows = body.scan %r{<tr id="blob_\d+".*?</tr>}m
    newest = place.photos_blobs.order(created_at: :desc).first

    assert_includes rows.first, %(alt="#{newest.filename}")
    assert_includes rows.first, '<picture><source srcset="/rails/active_storage/representations/'
    assert_includes rows.first, 'type="image/webp"><img alt="hairy.png" height="100" ' \
                                'class="border rounded" loading="lazy" ' \
                                'src="/rails/active_storage/representations/'
    assert_includes rows.first, %(disposition=inline">#{newest.filename}</a>)
    assert_includes rows.first, 'target="_blank" rel="noopener"'
    assert_includes rows.last, '<td data-cell="Preview"></td>'
    assert_includes rows.last, 'notes.txt</a>'
  end

  # A row with no page of its own carries its own Delete: the routes drew `destroy`
  # and no `edit`, so the table is the only place the button could stand. A table whose
  # rows have an edit page keeps the button there, as it always has.
  def test_a_row_routed_destroy_without_edit_offers_delete_on_the_table
    place = Place.order(:id).first
    blob = place.photos_blobs.order(created_at: :desc).first
    visit "/places/#{place.id}/photos"

    assert_includes body, 'data-cell="Delete"'
    assert_includes body, %(action="/places/#{place.id}/photos/#{blob.id}")
    assert_includes body, %(aria-label="Delete photo")
    assert_includes body, "data-turbo-confirm=\"Delete #{blob.filename}?"
    visit '/places'

    refute_includes body, 'data-cell="Delete"'
  end
end
