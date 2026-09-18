module Recourse
  # Which column a listing is dragged into order by, and so whether it is positioned at
  # all. Two questions with one answer, asked by the table that draws the grips, by the
  # search and the headings that stand down where they are drawn, and by the write a
  # drop lands on.
  module Positioned
    extend ActiveSupport::Concern

    included do
      # After the parent is found, which is what the default turns on.
      before_action { @recourse_position = recourse_position }
    end

  private

    # The model's own column by default — the `position` it keeps — and only on a page
    # where a place among rows means something: the rows one is counted within are the
    # rows the page lists, which the parent above it settles.
    #
    # A host overrides it where a listing is positioned by an order the model does not
    # keep. A plan holds a place among its service's plans and another among every plan
    # of its department, and which of the two a page is in is the page's answer rather
    # than the model's: a model keeps one column, and a second listing is a second
    # column that only its own controller knows about.
    #
    # Such a host owns the write as well as the listing. The gem draws a positions
    # controller under every index, and that one has to be told the same two things —
    # this column, and the rows to renumber — or a drop would move a row among rows the
    # page never showed.
    def recourse_position
      return unless resource_model?
      return unless Recourse.positioned? resource_class, @recourse_parent_association

      Recourse.position_column resource_class
    end

    # Whether these rows are ones a reader positions, which is the same question again.
    def positioned? = @recourse_position.present?
  end
end
