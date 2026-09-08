require 'test_helper'
require 'integration_case'

# The write behind the Clone link: the copy is built here rather than on the form, since
# a form sends columns and a record is not always one row.
class TestRecoursesClonesWrites < IntegrationCase
  # Two of them, so what the copy carries has an order to keep and not just a body.
  REMARKS = ['Worth copying', 'Worth copying as well'].freeze

  # The dummy's blobs are records without bytes -- the migration says so -- and attaching
  # one to a second record is what would send Active Storage looking for the file. A blob
  # that has been uploaded is identified already, so this is what a real one looks like.
  def setup
    super
    ActiveStorage::Blob.find_each { |blob| blob.update! identified: true }
  end

  def teardown
    Place.where(slug: 'a-copied-place').destroy_all
    Note.where(body: REMARKS).destroy_all
    Bookmark.where(topic: source).destroy_all
  end

  # One pass over the whole write: the children a place names come along under the new
  # row, the ones it does not are left where they were, and the counters and timestamps
  # a copy may not inherit are the copy's own.
  def test_a_copy_carries_what_its_model_names_and_nothing_else
    Bookmark.find_or_create_by! person: Person.order(:id).first, topic: source
    REMARKS.each { |body| Note.create! about: source, body: }

    @session.post "/places?cloned_id=#{source.id}", params: { place: copied_place_params }

    assert_equal 303, @session.response.status
    copy = Place.find_by! slug: 'a-copied-place'

    assert_equal source.audit.finding, copy.audit.finding
    assert_predicate copy.seal, :present?
    # Each keeps the place it was in rather than every one of them landing first: their
    # siblings are the copies beside them, so the order somebody put them in is part of
    # what was copied.
    assert_equal [[1, REMARKS.first], [2, REMARKS.second]],
                 copy.remarks.order(:position).pluck(:position, :body)
    # The blobs rather than the files: the copy writes attachment rows of its own
    # pointing at what the source already holds, so nothing is uploaded twice.
    assert_equal source.photos.map(&:blob), copy.photos.map(&:blob)
    # The bookmark is whoever kept the row rather than anything the row is made of, so
    # `recourse_cloned` never names it and the copy arrives unkept.
    assert_empty Bookmark.where(topic: copy)
    # `dup` copies the two Rails keeps, and Rails only fills a timestamp it finds
    # empty -- so without the reset a copy would claim the age of what it copied.
    assert_operator copy.created_at, :>, source.created_at
    # And the source is untouched: it still holds the one audit and the one seal it had.
    assert_equal 1, Audit.where(place: source).count
    assert_equal 1, Seal.where(place: source).count
  end

  # The id rides on the form's own action, so a rejected write still has it: what comes
  # back is the form again, and submitting it a second time copies as the first would.
  def test_a_rejected_copy_keeps_the_record_it_was_copying
    params = copied_place_params.merge slug: source.slug

    @session.post "/places?cloned_id=#{source.id}", params: { place: params }

    assert_equal 422, @session.response.status
    assert_includes body, %(action="/places?cloned_id=#{source.id}")
  end

private

  # The first place carries one of everything a copy can bring: an audit, a seal and
  # two photos.
  def source = Place.order(:id).first

  def copied_place_params
    { name: 'A copied place', slug: 'a-copied-place' }
  end
end
