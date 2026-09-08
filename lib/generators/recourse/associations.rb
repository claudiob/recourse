require_relative 'files'

module Recourse
  module Generators
    # Both sides of the association a `belongs_to` declares, written into a host's
    # files — by `recourse` for the model it has just made, and by `recourse:counters`
    # for the models already there. Each side is written only where it is missing, so
    # either may run over the same files twice. Private for the reason `Seeds` is.
    module Associations
      include Files

    private

      # The child's half of the count, appended before any trailing comment.
      # `touch:` keeps a cached table honest — `update_counters` bumps the column
      # without touching `updated_at` — but a `touch` already on the line is the
      # host's word, and it stands. A declaration wrapped over more lines than one
      # is left alone rather than edited blind.
      def count_from_belongs_to(file, name)
        return say_status :skip, "#{file} does not exist" unless exist? file

        declared = /^\s*belongs_to :#{Regexp.escape name.to_s}\b/
        wrapped = /#{declared}[^#\n]*,\s*(?:#[^\n]*)?$/.match? read(file)
        return say_status :skip, "#{file} wraps belongs_to :#{name} — count it by hand" if wrapped

        gsub_file file, /#{declared}.*$/ do |line|
          declaration, comment = line.match(/\A([^#]*?)(\s*#.*)?\z/).captures
          "#{declaration}#{counting_options declaration}#{comment}"
        end
      end

      # The declaration itself, where the model was written before this reference
      # was. Bare on purpose: `count_from_belongs_to` is what puts the counting
      # options on it, the same line it writes for a model made with the key.
      def declare_belongs_to(name)
        return if /^\s*belongs_to :#{Regexp.escape name.to_s}\b/.match? read(model_file)

        inject_into_class model_file, class_name, "  belongs_to :#{name}\n"
      end

      # And the far side, on the model the key points at — a foreign key read from
      # one side only is half a model. Nothing where that model is not written yet —
      # generate the parent first, or add the line by hand — nothing where it reads
      # its children back already, however its own line is worded, and nothing where
      # the class is not declared in the one-line form an injection can find.
      # Answers true only when it wrote the line, which is what earns more.
      def declare_has_many(klass:, children:, line:)
        parent = File.join 'app/models', "#{klass.underscore}.rb"
        return say_status :skip, "#{parent} does not exist" unless exist? parent
        return if /^\s*has_many :#{Regexp.escape children}\b/.match? read(parent)

        # Exactly the anchor Thor's inject_into_class matches — bare or before a
        # space — so what passes this guard is what the injection can really find.
        opened = /^\s*class #{Regexp.escape klass}(\n| )/.match? read(parent)
        return say_status :skip, "#{parent} hides class #{klass} — declare it by hand" unless opened

        inject_into_class parent, klass, "  #{line}\n"
        true
      end

      def counting_options(declaration)
        return '' if declaration.include? 'counter_cache'
        return ', counter_cache: true' if declaration.match?(/touch:/)

        ', counter_cache: true, touch: true'
      end
    end
  end
end
