module Recourse
  module Routes
    # What a `recourses` block draws around whatever the host wrote inside it: the
    # square that keeps one of its rows, and the join a listing writes.
    module Nested
    private

      # What a resource holds: the square that keeps one of its rows, the join a listing
      # writes, and whatever the host's own block declared — each under the resource's
      # own module, which is what every nested page relies on.
      def draw_within(keepable, arrangeable, through, block)
        addressable = addressable_rows?

        scope module: parent_resource.name do
          draw_bookmark if keepable && addressable
          draw_position if arrangeable && addressable
          draw_join through if through
          instance_exec(&block) if block
        end
      end

      # Whether this resource has rows to address one at a time. A bookmark names one
      # row and a position names one row, so neither means anything for a page a host
      # assembles — an aggregate has no ids to name — nor for a name with no class
      # behind it at all. Both were drawn for those anyway, at `/weeks/:week_id/bookmark`
      # and `/placeholders/:placeholder_id/bookmark`, where nothing linked to them and
      # anything reaching one raised.
      #
      # Answered from the class and nothing else. What a model keeps in the way of a
      # position column is a question for a request, not for this: it would reach for a
      # database before the routes are even finished.
      def addressable_rows?
        !Recourse.model(parent_resource.name).include? Recourse::Aggregate
      rescue Error
        false
      end

      # The place a row of an arranged table holds, at `/teams/5/position`. Recorded
      # nowhere, for the reason the bookmark gives: a tab and a bare-action button
      # both look under a resource, and this is neither. Drawn wherever an index is —
      # whether the model arranges anything is the model's word, and asking for it
      # here would reach for a database before the routes are even finished.
      def draw_position
        path = [current_module, 'positions'].compact.join '/'
        Controllers.define_missing path, ::PositionsController
        resource :position, only: :update
      end

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

      # The row a listing's Add and Remove write: one record joining the parent to the
      # row the button sat on, reached at `/people/1/teams/2/membership` and answered
      # by a controller of the gem's own rather than by the generic one.
      def draw_join(through)
        path = [current_module, through].compact.join '/'
        # Recorded under the listing it belongs to, which is how it finds its way back
        # there for a request that arrived without a referer. No tab and no button
        # come of it: a tab asks for a page and a button for an id-less write, and a
        # join draws neither.
        Recourse.nest current_module, path
        Controllers.define_missing path, JoinsController
        resource through.to_s.singularize.to_sym, only: %i[create destroy]
      end
    end
  end
end
