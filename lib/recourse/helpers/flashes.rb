module Recourse
  module Helpers
    # What a flash message is drawn as: the row it marks, and the words it leads somewhere.
    module Flashes
    private

      # What marks the row a write just landed on, and nothing at all on a page no write
      # brought about — which is every page but the one after a create or an update.
      def written_data
        written = flash[Recourse::WRITTEN]
        return {} if written.blank?

        { controller: 'written', written_row_value: written['row'] }
      end

      # The message with the record it names led to that record's page, where a write
      # landed on one the routes can show. Spliced around the label rather than rebuilt,
      # so the flash keeps the plain sentence for whoever else reads it.
      def written_message(key, message)
        written = flash[Recourse::WRITTEN]
        return message unless key.to_s == 'notice' && written&.dig('url')

        before, label, after = message.partition written['label']
        safe_join [before, label.presence && link_to(label, written['url']), after]
      end
    end
  end
end
