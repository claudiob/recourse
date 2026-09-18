module Recourse
  # The Ransack search behind an index: what a heading asked to sort by, what the
  # search box asked to match, and the relation those add up to.
  class Search
    # Predicates whose value is a list, which is how a multiple combobox submits:
    # one input holding every chosen value, comma-joined.
    LIST_PREDICATES = /_(not_)?in\z/

    # The Ransack object the form and the sort links read.
    attr_reader :query

    # A search of `relation` for the `q` parameters the request carried. A relation
    # rather than a model, so a host that narrowed the index is searched inside what
    # it narrowed to rather than around it — the model is still what answers for the
    # order, the eager loads and the allowlist, and a relation knows its own.
    #
    # `positioned` is the column this page is dragged into order by, or nil where it is
    # no such page. The controller's word rather than a question asked here: whether a
    # place among rows means anything depends on the level the page was reached at,
    # which the route knows and a relation does not — and a listing may be positioned by
    # a column the model never keeps, which only its own controller knows.
    def initialize(relation, params, positioned: nil)
      @model = relation.klass
      @positioned = positioned
      @query = relation.ransack conditions(params)
    end

    # The relation the index lists, in the order a heading asked for or the model's own.
    def scope
      scope = @query.result.reorder(*ordering)
      includes = @model.recourse_includes
      return scope if includes.blank?

      scope.includes includes
    end

  private

    # A heading's sort or the model's own order, each column with its empty rows last.
    # Ransack has ordered the relation already where a heading asked, but as the bare
    # column; the same sort is written again here so it ends the way every order does.
    #
    # And on a page somebody positions, the column they positioned it by — which is the
    # model's own order for a table positioned by the column it keeps, and is not for the
    # second listing of one, where a host named another. The order a table is read in
    # and the order somebody put it in have to be the same order, or a drop reports a
    # place that is no position at all.
    def ordering
      sorts = @query.sorts.map { |sort| sort.attr.public_send(sort.dir).nulls_last }
      return sorts if sorts.any?

      kept_first + Recourse.nulls_last(@model, @positioned&.to_sym || @model.recourse_order)
    end

    # The rows this viewer has kept, ahead of whatever the model orders by — but only
    # where nobody clicked a heading, which is the same word `recourse_order` answers
    # to. A semi-join rather than an outer one: it cannot multiply a row, and it
    # leaves the count pagy runs over this relation well-formed. Never on a positioned
    # table, where it would put one reader's kept rows ahead of the order everybody
    # else set by hand — and leave the numbers no longer running 1, 2, 3 down the page.
    def kept_first
      reflection = Recourse.bookmarks_for @model unless @positioned
      return [] unless reflection

      kept = Recourse.bookmarks_of(reflection).select reflection.foreign_key
      # `true` before `false` in PostgreSQL and `1` before `0` in the other two, so
      # descending puts the kept rows first wherever this runs.
      [@model.arel_table[@model.primary_key].in(kept.arel).desc]
    end

    # Ransack reads nothing it has not been shown — `ransackable_attributes` is the
    # allowlist — so what arrives here needs no permitting, only untangling: a list
    # predicate is gathered into the values it was picked as, and a filter nobody set
    # is dropped, since `IN ()` would match no row rather than every one.
    def conditions(params)
      # `?q=anything` reaches here as a String rather than as parameters of its own,
      # and a search nobody asked for reaches here as nil. Neither is a condition — and
      # neither is anything at all where the table is positioned by hand, since a search
      # or a filter shortens the page and a drop on a shortened one reports a place
      # among the rows that are left. Refused here rather than by leaving the form off
      # the page, because an address is typed as readily as it is clicked.
      return {} if @positioned || !params.is_a?(ActionController::Parameters)

      params.to_unsafe_h.filter_map do |key, value|
        value = list_values value if key.match? LIST_PREDICATES
        next if value.blank?

        [key, value]
      end.to_h
    end

    # A multiple select submits one value per pick, so a list predicate arrives as an
    # array — and as a lone value where a link carried one. Never split on a comma:
    # that was the shape before a combobox became a `<select>`, and it read `["48"]`,
    # the array written out, as one value, which Ransack cast to the 0 no row holds.
    # Emptied of its blanks after, since the way back to no filter submits one.
    def list_values(value) = Array(value).compact_blank
  end
end
