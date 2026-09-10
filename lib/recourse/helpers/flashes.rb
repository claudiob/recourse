module Recourse
  module Helpers
    # What a flash message is drawn as: its toast's theme, the row it marks, and the
    # words it leads somewhere.
    module Flashes
      # Bootstrap theme for each flash key, so a notice and an alert read apart.
      FLASH_THEMES = { 'notice' => 'theme-success', 'alert' => 'theme-danger' }

    private

      # Theme for one flash entry, falling back to a neutral one for a host's key.
      def flash_theme(key)
        FLASH_THEMES.fetch key.to_s, 'theme-primary'
      end

      # What marks the row a write just landed on, and nothing at all on a page no write
      # brought about — which is every page but the one after a create or an update.
      def written_data
        written = flash[Recourse::WRITTEN]

        { controller: 'written', written_row_value: written['row'] } if written.present?
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
