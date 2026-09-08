require 'rails/generators/active_record/model/model_generator'

require_relative 'altering'

module Recourse
  module Generators
    # What `rails generate recourse` writes a model with: Rails' own generator where
    # the resource is new, and a migration that adds to the table where the resource
    # is already drawn. `rails g recourse comment author:references` a second time is
    # how a column reaches a resource that has one, and Rails' own collision check —
    # right for a model being created — is what used to refuse it.
    class ActiveRecordGenerator < ActiveRecord::Generators::ModelGenerator
      include Altering

      # A source root is per-class rather than inherited, and this one renders the
      # parent's templates: without this line there is nothing to write.
      source_root ActiveRecord::Generators::ModelGenerator.source_root

      # The class being there is the point where the table is being altered, so the
      # check that it is not there is asked only of a resource being created.
      def check_class_collision
        super unless altering?
      end

      # `create_table` for a new resource, and for one already drawn the migration
      # Rails writes from a name it reads the table and the action out of —
      # `add_author_to_comments` becoming `add_reference :comments, :author`.
      def create_migration_file
        return super unless altering?
        return say_status :skip, "#{table_name} gains no column" if attributes.empty?

        # Named outright rather than read off `base_name`, which answers `recourse`
        # for this class: what is wanted is Active Record's own generator, the same
        # one this class extends, so a table is added to the way Rails adds to one.
        invoke 'active_record:migration', [alter_migration_name, *alter_migration_arguments]
      end

      # Both files are already written where the resource is already drawn, and both
      # would arrive without what the host has since put in them.
      def create_model_file
        super unless altering?
      end

      # And the module a namespaced model sits in, which is there for the same reason.
      def create_module_file
        super unless altering?
      end
    end
  end
end
