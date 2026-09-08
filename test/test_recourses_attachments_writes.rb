require 'test_helper'
require 'integration_case'

# What a form does with a file, which is add it rather than assign it. Rails' own
# writer replaces every attachment a record has and reads a blank field as an
# instruction to delete the lot, so these assert what no covered line stands in for:
# that a record editing its name keeps its files, and that adding one keeps the rest.
class TestRecoursesAttachmentsWrites < IntegrationCase
  def teardown
    ActiveStorage::Attachment.joins(:blob)
                             .where(active_storage_blobs: { filename: 'plan.txt' })
                             .each(&:purge)
  end

  # A shelf of files is added to. Assignment would have left this place holding only
  # the file chosen second. A place the seed attached nothing to, since the two it did
  # attach are rows recorded without bytes behind them — appending re-reads every file
  # already there, which is exactly what a page listing them never does.
  def test_a_submitted_file_joins_the_ones_already_attached
    place = Place.where.missing(:photos_attachments).order(:id).first
    patch place, photos: [upload]
    first = place.reload.photos_blobs.pluck :id
    patch place, photos: [upload]

    after = place.reload.photos_blobs.pluck :id

    assert_equal 2, after.size
    assert_empty first - after
  end

  # A form that names no file at all — which is what a browser sends for a file input
  # nobody touched — leaves them exactly as they were.
  def test_a_form_naming_no_file_leaves_the_files_alone
    place = Place.order(:id).first
    before = place.photos_blobs.pluck :id
    patch place, name: place.name

    assert_equal before, place.reload.photos_blobs.pluck(:id)
  end

  # And neither does one naming a blank, which is the shape that would have reached
  # Active Storage as `delete everything` had these been assigned.
  def test_a_blank_file_field_deletes_nothing
    place = Place.order(:id).first
    before = place.photos_blobs.pluck :id
    patch place, photos: ['']

    assert_equal before, place.reload.photos_blobs.pluck(:id)
  end

  # One file is replaced rather than added to, which is what a single attachment
  # means on a form — and the record's own page reads it out as a link to itself.
  def test_a_single_file_replaces_what_it_had_and_reads_on_the_record
    place = Place.order(:id).first
    patch place, floor_plan: upload

    assert_equal 'plan.txt', place.reload.floor_plan.filename.to_s
    visit "/places/#{place.id}"

    assert_includes body, '<div class="form-label">Floor plan</div>'
    assert_includes body, 'plan.txt</a>'
  end

private

  def upload
    Rack::Test::UploadedFile.new 'test/files/plan.txt', 'text/plain'
  end

  def patch(place, **attributes)
    @session.patch "/places/#{place.id}", params: { place: attributes }

    assert_equal 303, @session.response.status
  end
end
