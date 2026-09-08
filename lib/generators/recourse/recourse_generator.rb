require 'rails/generators/rails/resource/resource_generator'

require_relative 'altering'
require_relative 'associations'
require_relative 'loading'
require_relative 'references'
require_relative 'seeding'
require_relative 'validations'

module Recourse
  module Generators
    # `rails generate recourse` — everything `rails generate resource` writes, with
    # the route drawn by `recourses` and a seed file, so the gem serves the seven
    # screens for it and there is something to see on them.
    class RecourseGenerator < Rails::Generators::ResourceGenerator
      include Altering, Associations, Loading, References, Seeding, Validations

      # Nothing is rendered from the first path, which is there because it tells the
      # parent where to read `--help` from — a USAGE one directory above the source
      # root. The seed file is rendered from the second, `recourse:seed`'s own, so
      # that one engine writes every seed file this gem writes.
      source_root File.expand_path('templates', __dir__)
      source_paths << File.expand_path('seed/templates', __dir__)

      remove_invocation :resource_route

      # The model is written by this gem's own ORM generator rather than by Rails',
      # for the reason the controller is: a resource already drawn is one whose
      # table is there to add to, and Rails' generator can only create. `in:
      # :recourse` puts `recourse:active_record` ahead of `active_record:model` in
      # the hook's lookup, so a host on another ORM still reaches its own.
      hook_for :orm, in: :recourse, required: true

      class_option :seeds, type: :boolean, default: true,
                           desc: 'Add a seed file with a bare row and a filled one'

      # The generated controller inherits `RecoursesController`. A controller of the
      # host's own is what `Controllers.define_missing` steps aside for, so the
      # `ApplicationController` one `resource` writes would leave the resource with
      # no actions at all — the opposite of what generating it was for.
      # `in: :recourse` sends the hook's lookup to this gem's own controller
      # generator rather than Rails', which is what changes the parent class. It is
      # the base name of the class declaring the hook, so the parent's own
      # declaration resolved `rails:controller` and this one resolves
      # `recourse:controller`.
      #
      # Invoked with arguments and nothing else, exactly as the parent invokes it:
      # handing `invoke` an options hash is what stops `--pretend`, `--no-helper`
      # and every other switch meant for the controller from reaching it.
      #
      # Nothing where the resource is already drawn: its controller is written, and
      # would arrive without whatever the host has since put in it.
      hook_for :resource_controller, in: :recourse, required: true do |controller|
        invoke controller, [controller_name, options[:actions]] unless altering?
      end

      # A `references` attribute is a `belongs_to`, and a `belongs_to` is two sides of
      # one relationship: the parent gains the counter column and the `has_many` that
      # says what becomes of its children, and the child's own association gains the
      # option that fills the count.
      def add_associations
        counted_attributes.each do |attribute|
          add_counter_column attribute
          declare_belongs_to attribute.name if altering?
          count_from_belongs_to model_file, attribute.name
          declare_has_many klass: attribute.name.camelize, children: plural_name, line: far_side
        end
      end

      # Whatever the migration constrains, said again in the model: `title:string!`
      # earns a presence validator beside its `null: false`, `name:string{100}` a
      # length beside its limit, and `email:string:uniq` a uniqueness beside its
      # index. The gem reads a field's rules off the validators and never off the
      # schema, so a column constrained in the database alone constrains nothing
      # anyone filling in the form is told about.
      def add_validations
        declare_validations
      end

      # Rows to look at, in a file of their own under `db/seeds`, which `db/seeds.rb`
      # is taught to load. The same rows `rails generate recourse:seed` writes, drawn
      # from the attributes rather than from a table that does not exist yet.
      def create_seed_file
        return if altering?

        write_seed_file if options[:seeds]
      end

      # The line this generator exists for. `namespace:` nests it the way the routes
      # were asked for, so `rails generate recourse admin/market` draws `recourses
      # :markets` inside `namespace :admin`.
      def add_recourse_route
        return if altering? || options[:actions].present?

        route "recourses :#{file_name.pluralize}", namespace: regular_class_path
      end
    end
  end
end
