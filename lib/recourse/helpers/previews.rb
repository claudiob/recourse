module Recourse
  module Helpers
    # An attached file on a record's own page: named where a browser can show nothing
    # of it, and opened in place where it can.
    module Previews
    private

      # The attachments a record's own page reads out, which are the ones it keeps a
      # single file under. A `has_many_attached` is a table of its own — a page a host
      # nests under the record — and a column of filenames says more there than a list
      # squeezed into a value's row would.
      def shown_attachments
        attachment_names.reject { |name| Recourse.attachment_many? resource_model, name }
      end

      # One labelled file, in the grid a column's value sits in.
      def attachment_value(name)
        label = resource_model.human_attribute_name name

        tag.div class: ROW do
          safe_join [tag.div(label, class: 'form-label'), attachment_control(name)]
        end
      end

      # Nothing attached reads as the dash every other empty value reads as.
      def attachment_control(name)
        blob = attached_blobs(name).first
        read = blob ? attached_file(blob) : t('recourse.blank')

        tag.div read, class: 'form-control-plaintext'
      end

      # Named where that is all a page can do with it — a spreadsheet is a download and
      # nothing else — and offered as a picture where a browser draws one. The picture
      # is behind a `<details>` rather than on the page: a record's page is a column of
      # values a reader scans, and an image sitting open in one pushes the rest of them
      # down every time the page is opened.
      def attached_file(blob)
        return blob_link blob, blob.filename.to_s unless previewable? blob

        detailed blob.filename.to_s, attachment_preview(blob)
      end

      # Active Storage's own list of what a browser renders natively, so a host adding
      # `image/webp` to it adds it here too. `image/svg+xml` is deliberately not on it —
      # Rails keeps that one in `content_types_to_serve_as_binary` and refuses to serve
      # it inline at all, which is exactly the answer this question wants.
      def previewable?(blob)
        ActiveStorage.web_image_content_types.include? blob.content_type
      end

      # At the column's width, so a photograph shrinks to fit rather than deciding the
      # page's layout. Wrapped in the link the name would have been: opening a preview
      # is a look, and clicking what it drew is the download.
      def attachment_preview(blob)
        source = main_app.rails_blob_path blob, disposition: :inline
        image = tag.img src: source, alt: blob.filename.to_s, class: 'img-fluid mt-2'

        blob_link blob, image
      end
    end
  end
end
