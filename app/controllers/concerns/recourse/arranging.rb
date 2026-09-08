module Recourse
  # Which column a listing is dragged into order by, and so whether it is arranged at
  # all. Two questions with one answer, asked by the table that draws the grips, by the
  # search that stands down where they are drawn, and by the write a drop lands on.
  module Arranging
    extend ActiveSupport::Concern

    included do
      # After the parent is found, which is what the default turns on.
      before_action { @recourse_position = recourse_position }
    end

  private

    # The model's own column by default: the one key of `recourse_order` marked
    # `:positionable`, and only on a page where a position means something — the rows one
    # is counted within are the rows the page lists, which the parent above it settles.
    #
    # A host overrides it where a listing is arranged by an order the model does not
    # nominate. A plan holds a place among its service's plans and another among every
    # plan of its department, and which of the two a page is in is the page's answer
    # rather than the model's: a model names one, `recourse_order` refusing a second.
    #
    # Such a host owns the write as well as the listing. The gem draws a positions
    # controller under every index, and that one has to be told the same two things —
    # this column, and the rows to renumber — or a drop would move a row among rows the
    # page never showed.
    def recourse_position
      return unless resource_model? && resource_class.respond_to?(:recourse_order)
      return unless Recourse.arranges? resource_class, @recourse_parent_association

      Recourse.position_column resource_class
    end

    # Whether these rows are ones a reader arranges, which is the same question again.
    def arranged? = @recourse_position.present?
  end
end
