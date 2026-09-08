module Recourse
  module Helpers
    # The pictures a page draws: an icon on its own, and an icon standing in for a
    # heading where a column is too narrow to carry the word.
    module Pictures
    private

      # One icon, named by the concept it means rather than by what this set calls it.
      # Whatever else the caller hands over — a role, a tooltip's data, a class to hide
      # it by — rides along, a class of the caller's joining the two named here rather
      # than replacing them.
      def icon_tag(concept, label: nil, **options)
        classes = ['bi', "bi-#{Unicon[concept][:bootstrap]}", options.delete(:class)]

        tag.i class: classes.compact, aria: { label: }, **options
      end

      # A heading that is a picture: an action column's, as narrow as the icon in it,
      # and a counter's, headed with what it counts. Named to a screen reader, since
      # an icon alone says nothing to one, and given the tooltip that says the same
      # word to everyone else.
      def icon_heading(concept, title, **)
        icon_tag concept, label: title, role: :img, data: tooltip_on_top(title), **
      end

      def tooltip_on_top(title)
        # `bs_title` is what Bootstrap's tooltip reads, and the controller is what
        # makes one: Bootstrap never wires a tooltip on its own.
        { controller: 'tooltip', bs_placement: 'top', bs_title: title }
      end
    end
  end
end
