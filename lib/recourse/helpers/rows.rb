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

      # What the rows draw besides their own columns. A cell naming a `*_id` reads the
      # record it points at, and `MAX(updated_at)` over the relation only ever sees the
      # rows themselves -- so without this a table keeps a name, a phone or a ZIP that
      # the record it belongs to has since changed.
      #
      # Read off the objects rather than the database: the index eager-loads exactly
      # these, so every one of them is already in memory and this costs no query. And
      # written out to the microsecond, which is what `cache_key_with_version` keeps
      # too: a key expands a time by `to_s`, and two writes inside one second would
      # otherwise be one version.
      def rows_version(rows)
        drawn = reached rows, resource_model.recourse_includes

        drawn.filter_map { |one| one.try :updated_at }.max&.utc&.to_fs :usec
      end

      # The counts the rows draw, which the version above cannot see. A counter cache is
      # written by `update_counters`, which moves no timestamp, so a row whose children
      # changed is a row `MAX(updated_at)` still calls unchanged -- and the table went on
      # showing the count it was cached with. Read off the rows in memory like the
      # version is, so this costs no query either.
      def counters_version(rows)
        columns = Recourse.counters(resource_model).keys
        return if columns.empty?

        rows.map { |row| row.attributes.values_at(*columns) }
      end

      # And whatever the rows carry beyond their own columns. A host's relation may select
      # a value worked out from another table -- whether this ZIP is in this market, which
      # a join answers -- and nothing on the ZIP itself moves when the answer changes, so
      # neither the version above nor the counts beside it see it. Read off the rows in
      # memory like both of those, so this costs no query either.
      def selected_version(rows)
        extra = rows.first.attributes.keys - resource_model.column_names if rows.first
        return if extra.blank?

        rows.map { |row| row.attributes.values_at(*extra) }
      end

      # Every record the rows reach along `includes`, in any shape `includes` accepts:
      # a name, a list of them, or a hash naming what to follow from there.
      def reached(rows, names)
        Array.wrap(names).flat_map do |name|
          next along rows, name unless name.is_a? Hash

          name.flat_map { |one, nested| followed along(rows, one), nested }
        end
      end

      def followed(rows, nested) = rows + reached(rows, nested)

      def along(rows, name) = rows.flat_map { |row| Array.wrap row.public_send(name) }

      # Whether the table may be kept at all. A sorted or filtered one never is: two
      # requests can ask for one relation and want different rows, and only one of them
      # clicked a heading to say so.
      #
      # Nor a table of rows nothing versions. `cache` reads `MAX(updated_at)` off the
      # relation without asking whether there is such a column, and reference data — a
      # table of counties written by a migration and never again — keeps none. The same
      # question `keepable_menu?` asks of a menu, for the same reason.
      def cacheable_table?
        params[:q].blank? && resource_model.column_names.include?('updated_at')
      end
    end
  end
end
