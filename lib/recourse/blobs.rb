module Recourse
  # What a table of attachments reads off Active Storage's own model, which was never
  # asked how it wanted drawing. Extended onto the blob through the load hook Rails
  # publishes for it, so nothing here is a patch.
  module Blobs
    # A blob is known by the name it was uploaded under. Every other model answers
    # `:name`, and Active Storage has no such column — point a combobox at one
    # without this and the select raises.
    def recourse_label = :filename

    # The service's business rather than the reader's: where the file sits, what it
    # is called there, what it hashes to, and whatever the analyzer wrote down.
    def recourse_hidden = %i[key checksum service_name metadata]

    # Newest first, which is the order somebody looking at what was attached wants.
    def recourse_order = 'created_at desc'
  end
end

ActiveSupport.on_load :active_storage_blob do
  extend Recourse::Blobs
end
