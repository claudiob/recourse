require_relative 'helpers/actions'
require_relative 'helpers/bookmarks'
require_relative 'helpers/buttons'
require_relative 'helpers/cards'
require_relative 'helpers/cells'
require_relative 'helpers/choices'
require_relative 'helpers/colors'
require_relative 'helpers/comboboxes'
require_relative 'helpers/constraints'
require_relative 'helpers/counters'
require_relative 'helpers/deletions'
require_relative 'helpers/densities'
require_relative 'helpers/details'
require_relative 'helpers/examples'
require_relative 'helpers/fields'
require_relative 'helpers/filters'
require_relative 'helpers/formats'
require_relative 'helpers/inputs'
require_relative 'helpers/kinds'
require_relative 'helpers/limits'
require_relative 'helpers/names'
require_relative 'helpers/navigation'
require_relative 'helpers/parents'
require_relative 'helpers/pictures'
require_relative 'helpers/references'
require_relative 'helpers/resources'
require_relative 'helpers/refreshes'
require_relative 'helpers/routing'
require_relative 'helpers/rows'
require_relative 'helpers/themes'
require_relative 'helpers/searches'
require_relative 'helpers/shortcuts'
require_relative 'helpers/sidebars'
require_relative 'helpers/sorts'
require_relative 'helpers/tabs'
require_relative 'helpers/times'
require_relative 'helpers/values'
require_relative 'helpers/zones'

module Recourse
  # View helpers for the pages the gem renders, and what the parts share.
  module Helpers
    include Actions, Bookmarks, Buttons, Cards,
            Cells, Choices, Colors, Comboboxes, Constraints, Counters, Deletions, Densities,
            Details,
            Examples, Fields, Filters, Formats, Inputs, Kinds, Limits,
            Names, Navigation, Parents, Pictures, References, Refreshes,
            Routing,
            Resources, Rows, Searches, Shortcuts, Sidebars, Sorts, Tabs, Themes,
            Times, Values, Zones

    # The grid a record's own two pages lay an attribute out in: two columns on a large
    # viewport, and the same padding on both, so a value and the field that edits it sit
    # at the same height whichever page is open. The rule between rows belongs to the
    # show page alone — `.recourse-values` in the layout draws it.
    ROW = 'recourse-row pb-2 mb-3 lg:col-6'

    # Bootstrap theme for each flash key, so a notice and an alert read apart.
    FLASH_THEMES = { 'notice' => 'theme-success', 'alert' => 'theme-danger' }

    # Theme for one flash entry, falling back to a neutral one for a host's key.
    def flash_theme(key)
      FLASH_THEMES.fetch key.to_s, 'theme-primary'
    end

  private

    # What marks the row a write just landed on, and nothing at all on a page no write
    # brought about — which is every page but the one after a create or an update.
    def written_data
      row = flash[Recourse::WRITTEN]

      { controller: 'written', written_row_value: row } if row.present?
    end

    # `?q=anything` arrives as a String, which has no parameters to read — the
    # same test `Recourse::Search` makes, spelled the same way.
    def query_params
      params[:q].is_a?(ActionController::Parameters) ? params[:q] : {}
    end
  end
end
