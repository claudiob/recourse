module Recourse
  module Routes
    # What a `recourses` block draws around whatever the host wrote inside it: the
    # square that keeps one of its rows, and the place one of them holds.
    module Nested
    private

      # What a resource holds: the square that keeps one of its rows, the place a row
      # holds in a table somebody positioned, and whatever the host's own block declared —
      # each under the resource's own module, which is what every nested page relies on.
      def draw_within(keepable, positionable, retrievable, block)
        addressable = addressable_rows?

        scope module: parent_resource.name do
          draw_bookmark if keepable && addressable
          draw_position if positionable && addressable
          draw_retrieval if retrievable
          instance_exec(&block) if block
        end
      end

      # Whether this resource has rows to address one at a time. A bookmark names one
      # row and a position names one row, so neither means anything for a name with no
      # class behind it at all — and one was drawn anyway, at
      # `/placeholders/:placeholder_id/bookmark`, where nothing linked to it and
      # anything reaching it raised. Asked of the constant rather than the class:
      # loading a model while the routes draw is what Rails 8.2 warns about.
      def addressable_rows? = Object.const_defined? Recourse.model_name(parent_resource.name)

      # The place a row of a positioned table holds, at `/teams/5/position`. Recorded
      # nowhere, for the reason the bookmark gives: a tab and a bare-action button both
      # look under a resource, and this is neither. Drawn wherever an index is —
      # whether a model keeps a position column is a question for a request, and asking
      # it here would reach for a database before the routes are even finished.
      def draw_position
        path = [current_module, 'positions'].compact.join '/'
        Controllers.define_missing(path) { PositionsController }
        resource :position, only: :update
      end

      # The fetch a table's own button asks for, at `/providers/5/visits/retrieval`.
      # Where the rows came from is the host's to know, so the controller is the
      # host's to write and the gem only makes one where there is none — the same
      # bargain a bare action strikes. Recorded nowhere, for the reason the bookmark
      # gives: a tab and a bare-action button both look under a resource, and this is
      # neither.
      def draw_retrieval
        Controllers.define_missing [current_module, 'retrievals'].compact.join('/')
        collection { resource :retrieval, only: :create }
      end

      # The row a table's bookmark square writes: one record kept by whoever is looking,
      # at `/places/5/bookmark`. Deliberately not recorded through `Recourse.nest` — it
      # would sit directly under the resource, where a tab and a bare-action button both
      # look, and this is neither. Nothing has to remember where it hangs off either,
      # since the gem drew it: one segment under the resource, always.
      def draw_bookmark
        path = [current_module, 'bookmarks'].compact.join '/'
        Controllers.define_missing(path) { ::BookmarksController }
        resource :bookmark, only: %i[create destroy]
      end
    end
  end
end
