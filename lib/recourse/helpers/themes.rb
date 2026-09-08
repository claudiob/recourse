module Recourse
  module Helpers
    # The color scheme a host named, and the reader's own say in which one it is.
    module Themes
    private

      # The stylesheet that repaints Bootstrap's ramps in `Recourse.theme`, or nothing at
      # all where none is set — the stylesheet's own palette is already there. A file
      # rather than a block in the page: it is the same bytes on every request, so a
      # browser is asked for it once, and one attribute swap moves the whole page to
      # another palette. After the Bootstrap link and never before it, both blocks being
      # `:root`, so it wins on being later.
      def theme_stylesheet_link
        theme = Recourse.theme
        return unless theme

        tag.link rel: 'stylesheet', href: theme_stylesheet_path(theme),
                 data: { recourse_theme: '' }
      end

      # Where one palette is served from.
      def theme_stylesheet_path(theme) = "#{Recourse::THEMES_PATH}/#{theme}.css"

      # The reader's own palette and mode, put back before anything is painted. Inline
      # and classic rather than a module or a Stimulus controller, both of which run
      # after the first paint and would show the palette the server chose for an
      # instant first.
      def scheme_restore_script = render 'recourses/scheme'

      # What the sidebar's toggle needs to rotate: every palette there is, where they
      # are served from, and where to keep what the reader picked.
      def scheme_data
        {
          controller: 'scheme', action: 'scheme#rotate',
          scheme_themes_value: Recourse::THEMES.keys.to_json,
          scheme_path_value: Recourse::THEMES_PATH,
          scheme_storage_value: Recourse::SCHEME_STORAGE,
        }
      end
    end
  end
end
