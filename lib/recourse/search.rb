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
    def initialize(relation, params)
      @model = relation.klass
      @query = relation.ransack conditions(params)
    end

    # The relation the index lists. Ransack has already ordered it where a heading
    # asked, so the model's own order only applies when nothing did.
    def scope
      scope = @query.result
      scope = scope.order(*kept_first, @model.recourse_order) if @query.sorts.empty?
      includes = @model.recourse_includes
      return scope if includes.blank?

      scope.includes includes
    end

  private

    # The rows this viewer has kept, ahead of whatever the model orders by — but only
    # where nobody clicked a heading, which is the same word `recourse_order` answers
    # to. A semi-join rather than an outer one: it cannot multiply a row, and it
    # leaves the count pagy runs over this relation well-formed.
    def kept_first
      reflection = Recourse.bookmarks_for @model
      return [] unless reflection

      kept = Recourse.bookmarks_of(reflection).select reflection.foreign_key
      # `true` before `false` in PostgreSQL and `1` before `0` in the other two, so
      # descending puts the kept rows first wherever this runs.
      [@model.arel_table[@model.primary_key].in(kept.arel).desc]
    end

    # Ransack reads nothing it has not been shown — `ransackable_attributes` is the
    # allowlist — so what arrives here needs no permitting, only untangling: a list
    # predicate is split back into values, and a filter nobody set is dropped,
    # since `IN ()` would match no row rather than every one.
    def conditions(params)
      # `?q=anything` reaches here as a String rather than as parameters of its own,
      # and a search nobody asked for reaches here as nil. Neither is a condition.
      return {} unless params.is_a? ActionController::Parameters

      params.to_unsafe_h.filter_map do |key, value|
        next if value.blank?

        [key, key.match?(LIST_PREDICATES) ? value.to_s.split(',') : value]
      end.to_h
    end
  end
end
