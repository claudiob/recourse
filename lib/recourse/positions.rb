# Reopened for the order somebody put a table's rows in, which is neither the order
# they were made in nor one a heading sorts them into.
module Recourse
  # The column that order is kept in. The whole of the opt-in, the way a
  # `google_place_id` is the whole of a map's: a table keeping a place in each row has
  # said its rows are in an order, and there is nothing else for a model to declare.
  POSITION_COLUMN = 'position'

  # Whether a model's rows are arranged by hand. Asked of the type the model reports,
  # as a calendar asks about the two ends of its events — a `position` holding a job
  # title is a word about the row rather than a place among rows, and a table of those
  # is one this must leave alone.
  #
  # The guard earns more here than it does there. A map and a calendar only read, so a
  # column mistaken for one costs a link nobody follows; arranging writes, and it
  # writes at the first save — a new row takes a number and a deleted one closes the
  # gap behind it — so a wrong guess here is a column overwritten rather than a page
  # drawn wrong.
  def self.arrangeable?(model)
    model.column_names.include?(POSITION_COLUMN) &&
      model.type_for_attribute(POSITION_COLUMN).type == :integer
  end

  # The column a model is arranged by, or nil where nobody arranges it. The model's
  # own word rather than the convention, since that is what a host overrides — and nil
  # for a page whose rows answer no model at all.
  def self.position_column(model)
    model.recourse_position&.to_s if model.respond_to? :recourse_position
  end

  # The same as a list, for a caller subtracting it from a set of column names: a
  # position is nobody's to type and no table's to draw, since the row's own place in
  # the table already says it.
  def self.position_columns(model) = Array(position_column(model))

  # Whether *this* page is one the arranging means anything on, which is the same
  # question as whether the rows it lists are the rows a position is counted within.
  #
  # The association rather than the record it found: a key is what makes every row on
  # the page share the parent, and `parent_columns` narrows the relation by the same
  # one. A model nothing points away from — a flat list — is its own whole table, so
  # its index is that level too. What is neither is a page listing every row across
  # every parent, where the positions run 1, 2, 3, 1, 2, 3 and mean nothing side by
  # side: that page sorts and searches like any other, and offers no handle.
  def self.arranges?(model, association)
    return false unless position_column model

    association.present? || model.recourse_references.empty?
  end
end
