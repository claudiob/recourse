require 'rails/generators/active_record'

require_relative '../associations'
require_relative '../declared'
require_relative 'migrations'
require_relative 'nesting'

module Recourse
  module Generators
    # `rails generate recourse:counters` — the counter cache behind every
    # `belongs_to` of every model `recourses` serves, wherever a piece of one is
    # missing: the column on the parent, backfilled to the rows already there; the
    # option on the child that keeps it filled; and the `has_many` that reads it
    # back. A count already kept is left alone, so a run with nothing missing
    # writes nothing, and `rails db:migrate` applies whatever one wrote.
    class CountersGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration, Associations, Declared, Migrations, Nesting

      # Templates live beside this class, which is also what tells the parent where
      # to read `--help` from: a USAGE one directory above the source root.
      source_root File.expand_path('templates', __dir__)

      # One pass per belongs_to a served model declares, each writing its three
      # pieces — or whichever of them the host still lacks. Keys that would keep
      # their count in one shared column are all skipped instead: Rails would bump
      # that column once per key, which no single backfill can agree with.
      def add_counters
        counted_reflections.group_by { |child, reflection| counter_key child, reflection }
                           .each do |(parent, column), pairs|
          shared = "#{parent.table_name}.#{column} is shared — name each counter_cache by hand"
          next say_status :skip, shared if pairs.many?

          add_counter(*pairs.first)
        end
      end

    private

      def add_counter(child, reflection)
        add_counter_migration child, reflection
        count_from_belongs_to "app/models/#{child.name.underscore}.rb", reflection.name
        added = declare_has_many klass: reflection.klass.name, children: children_of(child),
                                 line: far_side_of(child, reflection)
        # A parent that just learned to read its children back gets somewhere to
        # read them: their index and a form to add one, nested under its own route.
        nest_route reflection.klass, children_of(child) if added
      end

      def counted_reflections
        declared_models.flat_map do |child|
          child.reflect_on_all_associations(:belongs_to)
               .select { |reflection| countable? child, reflection }
               .map { |reflection| [child, reflection] }
        end
      end

      def countable?(child, reflection)
        # A polymorphic key names no one table to count on, and a table still to be
        # created is a pending migration that carries its own counter already.
        !reflection.polymorphic? && child.table_exists? && reflection.klass.table_exists?
      end

      def counter_key(child, reflection)
        [reflection.klass, column_of(child, reflection)]
      end

      def children_of(child)
        # Demodulized, so an Admin::Job is read back as `jobs` — the same name Rails
        # gives the counter column.
        child.name.demodulize.underscore.pluralize
      end

      def far_side_of(child, reflection)
        naming = ", class_name: '#{child.name}'" if child.name.include? '::'
        # The parent infers its key from its own name, so a key called otherwise —
        # a `belongs_to :author` pointing here — is spelled out.
        key = reflection.foreign_key.to_s
        inferred = "#{reflection.klass.name.demodulize.underscore}_id"
        keying = ", foreign_key: :#{key}" if key != inferred
        # What becomes of the children follows what each child requires: one that
        # cannot exist without its parent goes with it, an optional one is kept.
        optional = reflection.options.fetch :optional, !child.belongs_to_required_by_default
        dependent = optional ? :nullify : :destroy

        "has_many :#{children_of child}#{naming}#{keying}, dependent: :#{dependent}"
      end
    end
  end
end
