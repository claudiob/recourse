module Recourse
  module Helpers
    # Whether a phone reads the chrome as icons alone or as icons with their words.
    module Densities
    private

      # Whether the reader asked for the words: the cookie the arrows write, read back so
      # the page arrives expanded rather than compact and then widened by a script.
      def expanded? = cookies[Recourse::DENSITY_STORAGE] == 'expanded'

      # What the arrows need to switch: the class they toggle and the cookie they write.
      def density_data
        { controller: 'density', action: 'density#toggle', density_storage_value: Recourse::DENSITY_STORAGE }
      end
    end
  end
end
