class AttachPhotosToPlaces < ActiveRecord::Migration[8.1]
  # Two on the first place and none on the rest, so a table of them has rows to draw
  # and the places beside it prove an empty one says so.
  PHOTOS = %w[floorplan.pdf frontage.jpg].freeze

  def change
    up_only { attach_photos }
  end

private

  # Recorded rather than uploaded: what a table of attachments reads is the blob's
  # own row — the name, the type, the size — and never the bytes behind it.
  def attach_photos
    place = Place.order(:id).first

    PHOTOS.each_with_index do |filename, index|
      blob = ActiveStorage::Blob.create_before_direct_upload!(
        filename:, byte_size: (index + 1) * 1024, checksum: "checksum-#{index}",
        content_type: filename.end_with?('.pdf') ? 'application/pdf' : 'image/jpeg'
      )
      ActiveStorage::Attachment.create! name: 'photos', record: place, blob:
    end
  end
end
