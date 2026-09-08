module Recourse
  module Helpers
    # The row partial a table renders: the host's for this resource where one is
    # defined — every column its own — and the gem's generic row otherwise.
    module Rows
    private

      # What the cache key reads so the table notices its row partial. Rails
      # resolves `render 'row'` per request, but the fragment's own digest never
      # follows it there — so a host `_row` added or edited after a fragment was
      # written would keep serving the row it replaced. The digestor walks the
      # resolved template's own dependencies too, so a partial a host's row
      # renders from inside expires the table as well.
      def row_digest
        row = lookup_context.find 'row', lookup_context.prefixes, true

        ActionView::Digestor.digest name: row.virtual_path, format: :html, finder: lookup_context
      end

      # Whether the table may be kept at all. A sorted or filtered one never is: two
      # requests can ask for one relation and want different rows, and only one of them
      # clicked a heading to say so.
      #
      # Nor a page of rows a host assembled. An aggregate keeps no columns, so its rows
      # are plain objects rather than records — and a plain object is asked for its
      # cache key the same way, which for anything built on `ActiveModel::Model` is a
      # `to_param` of nil. Every row of every page then reads as the same key, so the
      # second page of one would be served the first page of another. A host can answer
      # `cache_key` itself and be right, but nothing makes it, and being wrong here is
      # somebody else's page — so these are drawn each time instead.
      #
      # Nor a table of rows nothing versions. `cache` reads `MAX(updated_at)` off the
      # relation without asking whether there is such a column, and reference data — a
      # table of counties written by a migration and never again — keeps none. The same
      # question `keepable_menu?` asks of a menu, for the same reason; an aggregate has
      # no columns at all and so answers no here as well.
      def cacheable_table?
        params[:q].blank? && resource_model.column_names.include?('updated_at')
      end
    end
  end
end
