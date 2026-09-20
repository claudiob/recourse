# Reopened for which columns a screen uses at all, which the table, the show page and
# the form each ask before they ask what order to read them in.
module Recourse
  # Columns the database writes itself out of the others, which a form never offers: a
  # stored generated column takes no value, and Postgres refuses the one a form would send.
  # @param model [Class] the model the page is about.
  # @return [Array<String>] the names of its generated columns.
  def self.virtual_columns(model)
    model.columns.select(&:virtual?).map(&:name)
  end

  # Columns a user may set: the form offers these, the show page reads these out, and
  # `create` permits these. A counter cache is none of a user's business — Rails keeps
  # it, so a form that offered one would let it be typed over, and neither is a column
  # the database generates: it takes no value at all.
  def self.editable_columns(model)
    ordered model, model.column_names - ['id', *TIMESTAMPS] - counters(model).keys -
                   hidden_columns(model) - virtual_columns(model)
  end

  # Columns no screen shows: whatever the model asked to hide through `recourse_hidden`
  # — one name or a list, taken either way — the column Rails reserves for single table
  # inheritance, and the place a row holds where somebody positioned the table. A class
  # name is machinery rather than something to read out, and a position is set by
  # dragging the row rather than typed beside it.
  def self.hidden_columns(model)
    Array(model.recourse_hidden).map(&:to_s) +
      [model.inheritance_column, *position_columns(model)]
  end

  # The names a column is validated under: its own, and — where it is a foreign key
  # — the association's, since `belongs_to` validates the record it points at rather
  # than the number pointing there. Two questions where a column is a key, one
  # everywhere else.
  def self.validated_names(column)
    [column, column.delete_suffix('_id')].uniq
  end
end
