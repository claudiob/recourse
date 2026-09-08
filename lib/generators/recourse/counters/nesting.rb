require_relative '../files'

module Recourse
  module Generators
    # The route a fresh `has_many` earns: the children nested under the parent's
    # own declaration, so the count on the parent's index has somewhere to link —
    # their rows, and a form to add one, which is what a bare nested `recourses`
    # answers by default. Private for the reason `Seeds` is.
    module Nesting
      include Files

    private

      # Turns `recourses :providers` into a block nesting `recourses :bookings`,
      # or joins a block already open. A line declaring several resources at once
      # is skipped rather than nested blind — a block nests under every name on it
      # — and a parent the routes never drew has nowhere to nest at all.
      def nest_route(parent, children)
        file = 'config/routes.rb'
        parents = parent.name.demodulize.underscore.pluralize
        line = declaration_of parents
        return say_status :skip, "#{file} draws no `recourses :#{parents}`" unless line

        if line.match?(/:#{parents},\s*:/)
          return say_status :skip, "`recourses :#{parents}` shares its line — nest by hand"
        end

        nest file, line, children unless nested? file, line, children
      end

      # The parent's own declaration is the shallowest one: a same-named line
      # sitting deeper is nested under something else, and no place to nest more.
      def declaration_of(parents)
        return unless exist? 'config/routes.rb'

        read('config/routes.rb').scan(/^[ \t]*recourses :#{parents}\b[^\n]*/)
                                .min_by { |one| one[/\A[ \t]*/].length }
      end

      def nest(file, line, children)
        indent = line[/\A[ \t]*/]
        nested = "#{indent}  recourses :#{children}\n"
        return inject_into_file file, nested, after: "#{line}\n" if line.end_with? ' do'

        gsub_file file, line, "#{line} do\n#{nested}#{indent}end"
      end

      # True where the parent's block already nests the children, however their
      # actions are worded. Only a block nests, and it runs to the `end` at the
      # parent's own indentation.
      def nested?(file, line, children)
        return false unless line.end_with? ' do'

        indent = line[/\A[ \t]*/]
        block = read(file).lines.drop_while { |one| one.chomp != line }
        block.take_while { |one| one.chomp != "#{indent}end" }
             .any? { |one| one.match?(/recourses :#{children}\b/) }
      end
    end
  end
end
