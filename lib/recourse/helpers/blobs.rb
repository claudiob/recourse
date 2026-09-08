module Recourse
  module Helpers
    # What a page reads off Active Storage's own objects: the row behind a file, and
    # the way to open the file itself. Paired with `Recourse::Blobs`, which is what
    # tells the blob model how it wants drawing.
    module Blobs
    private

      # True for the filename of a blob, and for nothing else — a host model with a
      # column of that name is drawing its own value, not Active Storage's.
      def blob_filename?(column)
        column == 'filename' && blob_resource?
      end

      # By name, so an app with no Active Storage never mentions the constant.
      def blob_resource?
        resource_model.name == 'ActiveStorage::Blob'
      end

      # The file itself, in a tab of its own: an admin opening one is leaving the
      # page they were reading, and a download that replaced it would lose their place.
      # Whatever the caller hands over is what the link reads as — the name it was
      # uploaded under in a table, and the picture itself under an opened preview.
      def blob_link(blob, read)
        link_to read, main_app.rails_blob_path(blob, disposition: :attachment),
                target: '_blank', rel: 'noopener'
      end

      # The blobs one attachment holds, as a list whichever kind it is. Read through
      # the associations Active Storage generated rather than through the reader it
      # named, which is the trade `AttachmentResolution` already makes next door.
      def attached_blobs(name)
        return resource_record.association(:"#{name}_blobs").reader.to_a if
          Recourse.attachment_many? resource_model, name

        Array resource_record.association(:"#{name}_blob").reader
      end

      # And the names they were uploaded under, which is what a reader is told a
      # record is holding.
      def attached_filenames(name)
        attached_blobs(name).map { |blob| blob.filename.to_s }
      end
    end
  end
end
