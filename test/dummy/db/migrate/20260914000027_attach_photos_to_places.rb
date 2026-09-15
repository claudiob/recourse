class AttachPhotosToPlaces < ActiveRecord::Migration[8.1]
  # A note a browser draws nothing of, a photograph it would, and a picture a browser
  # draws which two places share — so a table of them has every kind of row, and taking
  # one off a place leaves the file where the other place still points at it.
  FILES = {
    'notes.txt' => 'text/plain', 'frontage.jpg' => 'image/jpeg',
    'hairy.png' => 'image/png',
  }.freeze

  def change
    up_only { attach_photos }
  end

private

  # Recorded rather than uploaded: what a table of attachments reads is the blob's
  # own row — the name, the type, the size — and never the bytes behind it. Marked
  # identified, as an uploaded blob is, or the first record to take one on would send
  # Active Storage reading bytes that were never written.
  def attach_photos
    first, second = Place.order(:id).first 2
    blobs = FILES.each_with_index.map do |(filename, content_type), index|
      blob filename, content_type, index
    end

    blobs.each { |one| ActiveStorage::Attachment.create! name: 'photos', record: first, blob: one }
    ActiveStorage::Attachment.create! name: 'photos', record: second, blob: blobs.last
    ActiveStorage::Attachment.create! name: 'floor_plan', record: second, blob: blobs.last
  end

  def blob(filename, content_type, index)
    ActiveStorage::Blob.create_before_direct_upload! filename:, content_type:,
                                                     byte_size: (index + 1) * 1024,
                                                     checksum: "checksum-#{index}",
                                                     metadata: { identified: true }
  end
end
