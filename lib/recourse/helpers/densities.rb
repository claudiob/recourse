module Recourse
  module Helpers
    # Whether a phone reads the chrome as icons alone or as icons with their words.
    module Densities
    private

      # Whether the reader asked for the words: the cookie the ruler writes, read back so
      # the page arrives expanded rather than compact and then widened by a script.
      def expanded? = cookies[Recourse::DENSITY_STORAGE] == 'expanded'

      # What the ruler needs to switch: the class it toggles and the cookie it writes.
      def density_data
        { controller: 'density', action: 'density#toggle', density_storage_value: Recourse::DENSITY_STORAGE }
      end
    end
  end
end
