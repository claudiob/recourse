module Recourse
  module Routes
    # What a `recourses` block draws around whatever the host wrote inside it: the
    # square that keeps one of its rows.
    module Nested
    private

      # What a resource holds: the square that keeps one of its rows, and whatever the
      # host's own block declared — each under the resource's own module, which is what
      # every nested page relies on.
      def draw_within(keepable, block)
        scope module: parent_resource.name do
          draw_bookmark if keepable && addressable_rows?
          instance_exec(&block) if block
        end
      end

      # Whether this resource has rows to address one at a time. A bookmark names one
      # row, which means nothing for a name with no class behind it at all — and one was
      # drawn anyway, at `/placeholders/:placeholder_id/bookmark`, where nothing linked
      # to it and anything reaching it raised.
      def addressable_rows? = Recourse.model?(parent_resource.name).present?

      # The row a table's bookmark square writes: one record kept by whoever is looking,
      # at `/places/5/bookmark`. Deliberately not recorded through `Recourse.nest` — it
      # would sit directly under the resource, where a tab and a bare-action button both
      # look, and this is neither. Nothing has to remember where it hangs off either,
      # since the gem drew it: one segment under the resource, always.
      def draw_bookmark
        path = [current_module, 'bookmarks'].compact.join '/'
        Controllers.define_missing path, ::BookmarksController
        resource :bookmark, only: %i[create destroy]
      end
    end
  end
end
