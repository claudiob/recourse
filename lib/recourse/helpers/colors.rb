module Recourse
  module Helpers
    # The primary color, where a host has named one.
    module Colors
    private

      # The `:root` block that makes `Recourse.color` the primary one, or nothing at all
      # where no color is named — Bootstrap's own blue is already there, and a palette
      # names its own lead accent in its own file. It wins on being later rather than on
      # being more specific, every selector being `:root`, so it belongs after both the
      # stylesheet link and the palette's, and never before either.
      def primary_color_style
        color = Recourse.color
        return unless color

        render 'recourses/color', color: color, ink: Recourse.ink(color)
      end
    end
  end
end
