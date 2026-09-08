module Recourse
  module Helpers
    # The reader's own say in whether a page is light or dark.
    module Schemes
    private

      # What the sidebar's toggle needs to flip the mode: where to keep what the reader
      # picked, so the layout's script can put it back on the next visit.
      def scheme_data
        { controller: 'scheme', action: 'scheme#rotate', scheme_storage_value: Recourse::SCHEME_STORAGE }
      end
    end
  end
end
