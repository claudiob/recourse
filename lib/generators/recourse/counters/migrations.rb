module Recourse
  module Generators
    # The migration a counter cache stands on: the column where the parent lacks
    # one, backfilled from the rows already there — or the backfill alone, where a
    # column arrived without the option that keeps it, and so holds counts nobody
    # maintained. Private for the reason `Seeds` is.
    module Migrations
    private

      def add_counter_migration(child, reflection)
        @column = column_of child, reflection
        @parent_table = reflection.klass.table_name
        @creating = !reflection.klass.column_names.include?(@column)
        return if counted?(reflection) || pending_migration?

        @child_table = child.table_name
        @foreign_key = reflection.foreign_key
        @primary_key = reflection.association_primary_key
        migration_template 'counter_migration.rb', "db/migrate/#{migration_name}.rb"
      end

      def counted?(reflection)
        # A count already kept needs nothing. Anything else earns one migration,
        # unless an earlier run wrote it and `db:migrate` has yet to notice.
        !@creating && reflection.options[:counter_cache].present?
      end

      def migration_name
        @creating ? "add_#{@column}_to_#{@parent_table}" : "backfill_#{@column}_on_#{@parent_table}"
      end

      def pending_migration?
        # Found by glob, the way References finds the ORM's migration: Rails'
        # migration_exists? answers the same question through an unpublished module.
        Dir.glob(File.join(destination_root, 'db/migrate', "*_#{migration_name}.rb")).any?
      end

      def column_of(child, reflection)
        # A counter_cache with a name of its own is checked, and filled, under it.
        return reflection.counter_cache_column.to_s if reflection.options[:counter_cache]

        "#{children_of child}_count"
      end
    end
  end
end
