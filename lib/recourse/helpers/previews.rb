module Recourse
  module Helpers
    # An attached file on a record's own page: shown where a browser can make a picture
    # of it, and named where it cannot, either opening the file.
    module Previews
    private

      # The attachments a record's own page reads out, which are the ones it keeps a
      # single file under. A `has_many_attached` is a table of its own — a page a host
      # nests under the record — and a row of pictures says more there than a list
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

      # The picture where there is one to draw, and the name where there is not — a
      # spreadsheet is a download and nothing else. Either opens the file.
      def attached_file(blob)
        blob_preview(blob) || blob_link(blob, blob.filename.to_s)
      end
    end
  end
end
