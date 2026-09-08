require_relative 'files'

module Recourse
  module Generators
    # Whether this run is adding to a resource the host already has. Private for
    # the reason `Seeds` is.
    module Altering
      include Files

    private

      # True where the routes file already draws this resource, which is the whole
      # test: `recourses :comments` is only ever drawn for a table that exists, so
      # a second `rails g recourse comment author:references` means adding to that
      # table rather than creating it. Read off the file rather than off the loaded
      # route set, since a generator writes to a root that need not be the one this
      # process booted — and a resource drawn some other way is created, and says so
      # by failing the way it always did.
      def altering?
        return false unless exist? 'config/routes.rb'

        read('config/routes.rb').match?(/^\s*recourses .*:#{Regexp.escape plural_name}\b/)
      end

      # Named for what it does, since Rails reads the table and the action out of a
      # migration's own name: `add_author_to_comments` writes `add_reference`.
      def alter_migration_name
        "add_#{attributes.map(&:name).join '_and_'}_to_#{table_name}"
      end

      # The attributes spelled the way they were typed, for a generator that parses
      # them again. Thor has already eaten the raw arguments by the time a command
      # runs, and `GeneratedAttribute#to_s` writes a type's options and its `:uniq`
      # but never the `!` that asked for `null: false` — which belongs on the type,
      # so `slug:string:uniq` becomes `slug:string!:uniq` and not `slug:string:uniq!`.
      # A reference needs none of it: Rails marks the one it adds `null: false` by
      # itself, because `belongs_to` requires what it points at.
      def alter_migration_arguments
        attributes.map do |attribute|
          next attribute.to_s if attribute.reference? || attribute.attr_options[:null] != false

          attribute.to_s.sub(/\A([^:]+:[^:]+)/, '\1!')
        end
      end
    end
  end
end
