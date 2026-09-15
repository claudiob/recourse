module Recourse
  module Helpers
    # What a page reads off Active Storage's own objects: the row behind a file, the way
    # to open the file itself, and the picture a browser can make of it. Paired with
    # `Recourse::Blobs`, which is what tells the blob model how it wants drawing.
    module Blobs
      # How tall a preview stands on the page. The picture behind it is made twice as
      # tall, so a screen with two pixels to the point has every one of them.
      PREVIEW_HEIGHT = 100

      # How a picture is saved for the trip: lossy at a quality the eye forgives at this
      # size, and stripped of whatever the camera wrote — neither is worth the bytes.
      PREVIEW_SAVER = { quality: 80, strip: true }.freeze

    private

      # True for the filename of a blob, and for nothing else — a host model with a
      # column of that name is drawing its own value, not Active Storage's.
      def blob_filename?(column) = column == 'filename' && blob_resource?

      # By name, so an app with no Active Storage never mentions the constant.
      def blob_resource? = resource_model.name == 'ActiveStorage::Blob'

      # The file itself, in a tab of its own: an admin opening one is leaving the page
      # they were reading, and a file that replaced it would lose their place. Inline,
      # so the browser shows a picture and plays a video rather than saving either.
      # Whatever the caller hands over is what the link reads as.
      def blob_link(blob, read)
        link_to read, main_app.rails_blob_path(blob, disposition: :inline),
                target: '_blank', rel: 'noopener'
      end

      # A picture of the file where Active Storage can make one — the image itself
      # scaled down, or the frame a previewer takes of a video or a PDF — inside the link
      # that opens the whole file. Nothing for a file nothing can draw. A `<picture>`
      # offering WebP first, the smallest a browser can be sent, and the file's own kind
      # under it for one that cannot take WebP; either at half the pixels it was made
      # with, and the height is the attribute's, so no class here may say `height: auto`,
      # as `img-thumbnail` does.
      def blob_preview(blob)
        return unless blob.representable?

        blob_link blob, tag.picture(safe_join([preview_source(blob), preview_image(blob)]))
      end

      def preview_source(blob)
        tag.source srcset: preview_path(blob, format: :webp, saver: PREVIEW_SAVER),
                   type: 'image/webp'
      end

      def preview_image(blob)
        image_tag preview_path(blob), alt: blob.filename.to_s, height: PREVIEW_HEIGHT,
                                      class: 'border rounded', loading: 'lazy'
      end

      # The address of one scaling of the file, made on first request and kept.
      def preview_path(blob, **saving)
        representation = blob.representation resize_to_limit: [nil, PREVIEW_HEIGHT * 2], **saving

        main_app.rails_representation_path representation
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
