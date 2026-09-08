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
    # `arranged` is the controller's word rather than a question asked here: whether
    # a position means anything depends on the level the page was reached at, which
    # the route knows and a relation does not.
    #
    # A collection that is no relation at all is held as it was handed over. That is a
    # page a host assembled out of other models' records rather than read off a table —
    # the weeks a month came to, the memos of everyone on a team — and there is nothing
    # to search it by, nothing to sort it by and nothing to eager-load, which is what
    # `Aggregate` already answers for each of those. Only the paging is left, and a
    # collection can be paged — an `Array` of one, which pagy counts and slices
    # itself rather than asking a database to.
    def initialize(relation, params, arranged: false)
      @relation = relation
      @arranged = arranged
      return unless relation.respond_to? :ransack

      @model = relation.klass
      @query = relation.ransack conditions(params)
    end

    # The relation the index lists. Ransack has already ordered it where a heading
    # asked, so the model's own order only applies when nothing did — and a collection
    # nobody can search is listed in the order the host assembled it in.
    def scope
      return @relation unless @query

      scope = @query.result
      scope = scope.order(*kept_first, Recourse.order_for(@model)) if @query.sorts.empty?
      includes = @model.recourse_includes
      return scope if includes.blank?

      scope.includes includes
    end

  private

    # The rows this viewer has kept, ahead of whatever the model orders by — but only
    # where nobody clicked a heading, which is the same word `recourse_order` answers
    # to. A semi-join rather than an outer one: it cannot multiply a row, and it
    # leaves the count pagy runs over this relation well-formed. Never on an arranged
    # table, where it would put one reader's bookmarks ahead of the order everybody
    # else set by hand.
    def kept_first
      reflection = Recourse.bookmarks_for @model unless @arranged
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
      # and a search nobody asked for reaches here as nil. Neither is a condition —
      # and neither is anything at all where the table is arranged by hand, since a
      # sort or a filter would draw those rows in an order nobody set and a drag would
      # then write a position against what the reader is looking at. Refused here
      # rather than by leaving the controls off the page, because a URL is typed as
      # readily as it is clicked.
      return {} if @arranged || !params.is_a?(ActionController::Parameters)

      params.to_unsafe_h.filter_map do |key, value|
        next if value.blank?

        [key, key.match?(LIST_PREDICATES) ? value.to_s.split(',') : value]
      end.to_h
    end
  end
end
