module Recourse
  module Helpers
    # A counter cache's column in a table: an icon heading over bare figures, or —
    # where the table is wide enough to read them — the counted model's own words.
    module Counters
    private

      # The class a counter's cells carry, which is what sizes the column like the
      # action columns beside it rather than like the columns carrying text.
      def counter_class(column)
        'recourse-counter' if resource_model.recourse_counters.key? column
      end

      # A figure, and the word saying what it counts. The `aria-label` carries both,
      # since a link whose whole text is a number announces as `10` and nothing else.
      # A span where there is no index to link to, so an unlinked count is named the
      # same as a linked one.
      def counter_cell(resource, value, association)
        # Delimited like every other count on the page: the filter menu beside the
        # table already reads 38,405, and one figure in two spellings reads as two.
        count = number_with_delimiter value
        counted = counter_counted count, value, association
        named = counter_naming count, association
        path = resource_controller_path
        nested = nested_path_of path, association
        return tag.span(counted, **named) unless nested && routed?(nested, 'index')

        turbo_link_to counted, nested_url(resource, path, nested, :index), **named
      end

      # The two forms of one count, of which a stylesheet ever shows one: the bare
      # figure where the column is a square, and the figure with the counted model's
      # own word where the table is wide enough to read it. `count:` is what makes it
      # `1 place` rather than `1 places`, and `lower:` what leaves it reading as a
      # phrase. Written out twice rather than as a figure and a suffix, so that each
      # is a whole thing to show or hide — which is what lets the tooltip ride on the
      # first of them and keep quiet beside the second.
      def counter_counted(count, value, association)
        title = Recourse.model_title association.klass
        word = Recourse.model_title association.klass, count: value, lower: true

        safe_join [
          tag.span(count, class: 'recourse-counter-figure', data: tooltip_on_top(title)),
          tag.span("#{count} #{word}", class: 'recourse-counter-word'),
        ]
      end

      # The label reads the figure and the word, which is the order somebody hearing it
      # needs them in — and it is on the link either way, since nothing is hidden from
      # a screen reader by a width.
      def counter_naming(count, association)
        { aria: { label: "#{count} #{Recourse.model_title association.klass}" } }
      end

      # Where the counted rows were nested under this resource, read off the routes
      # rather than joined onto the parent's path: a `namespace` between the two is
      # part of the address and nothing here would know to put it back.
      def nested_path_of(path, association)
        Recourse.nested_under(path).find { |one| one.split('/').last == association.name.to_s }
      end

      # The icon the sidebar and the breadcrumb already draw for the counted model,
      # speaking the heading's word to a screen reader — and that word itself, for the
      # table with room to read it. Exactly one of the two is ever shown, and the icon's
      # tooltip leaves with the icon: what cannot be hovered repeats nothing.
      def counter_title(association)
        title = Recourse.model_title association.klass
        icon = icon_heading association.klass.recourse_icon, title,
                            class: 'recourse-counter-icon'

        safe_join [icon, tag.span(title, class: 'recourse-counter-word')]
      end
    end
  end
end
