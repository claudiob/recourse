module Recourse
  module Helpers
    # The bookmark a table's first column carries: one square per row, hollow where
    # the viewer has not kept it and filled where they have.
    module Bookmarks
    private

      # How this model's bookmarks point back at it, or nil where it keeps none and
      # the column is not drawn at all. Looked up once per render, like the model.
      def resource_bookmarks
        return @resource_bookmarks if defined? @resource_bookmarks

        @resource_bookmarks = Recourse.bookmarks_for resource_model
      end

      # The rows this viewer has kept, read once for the page rather than a query a
      # row: a page is twenty rows and the answer is one integer column.
      def bookmarked_ids
        @bookmarked_ids ||= Recourse.bookmarks_of(resource_bookmarks)
                                    .pluck(resource_bookmarks.foreign_key).to_set
      end

      # What the table's cache key carries for the bookmarks, and nil where there are
      # none. The rows are the model's own and never change when a bookmark does, so
      # without this a fragment drawn before the last click outlives it — and the
      # ids are the viewer's, so this is also what keeps one agent's icons off
      # another's page. The name leads for the reason the join's does: an expanded
      # key renders `nil` and `[]` alike.
      def bookmark_digest
        [:bookmarked, *bookmarked_ids.to_a.sort] if resource_bookmarks
      end

      # The class that tints a kept row, and nothing at all where the viewer has not
      # kept it — or where this model keeps none, since `bookmarked_ids` has no column
      # to read then. The square already says which rows are theirs, and says it to a
      # reader who cannot see a tint; this is what a page of twenty is scanned by.
      def bookmark_row_class(record)
        'recourse-kept' if resource_bookmarks && bookmarked_ids.include?(record.id)
      end

      # The column's heading: the hollow square on the header row — the column is as
      # narrow as the icon in it — and the word on every other, which is what each
      # `data-cell` labels itself with, the way an action column's does.
      def bookmark_header
        label = t 'recourse.bookmark'
        return label unless @recourse_headers

        icon_heading :bookmark, label
      end

      # Kept or not, one square either way: the same path with the verb reversed, so
      # the button toggles by flipping the method Rails already wrote into the form.
      def bookmark_button(record)
        kept = bookmarked_ids.include? record.id
        label = t "recourse.#{kept ? 'unbookmark' : 'bookmark'}"

        button_to bookmark_icon(kept, label), bookmark_url(record),
                  method: kept ? :delete : :post, form_class: 'd-inline-block',
                  class: 'btn btn-sm btn-link p-0 border-0 lh-1',
                  **bookmark_data(kept, label)
      end

      def bookmark_icon(kept, label)
        icon_tag kept ? :bookmarked : :bookmark, label:
      end

      # What the Stimulus controller flips, and the wording it cannot look up itself:
      # a `.js` file has no `t`, so the message it may have to show travels with it.
      def bookmark_data(kept, label)
        # No tooltip, unlike every other icon here. This one is in every row rather
        # than in a heading, and a label that follows the cursor down a column of
        # squares is noise — the `aria-label` still names it for a reader who cannot
        # see which way the square is filled.
        data = {
          controller: 'bookmark', bookmark_kept_value: kept,
          bookmark_error_value: t('recourse.bookmark_error'),
        }

        { aria: { label:, pressed: kept }, data: }
      end

      def bookmark_url(record)
        url_for controller: "/#{resource_controller_path}/bookmarks", action: :create,
                "#{resource_model.model_name.singular}_id": record.id
      end
    end
  end
end
