# Reopened for the order an index lists its rows in.
module Recourse
  # What `recourse_order` comes to as Arel, every column ending in NULLS LAST: a row
  # with nothing in the column is what a reader is least looking for, whichever way
  # the rows run. Extended onto `Recourse`, so this is `Recourse.nulls_last`.
  module Orders
    # A Symbol is that column ascending and a Hash is each column in its direction,
    # both with the empty rows last. Anything else — a SQL string a host wrote — is
    # taken as written.
    def nulls_last(model, order)
      directions = order.is_a?(Symbol) ? { order => :asc } : order
      return [*order] unless directions.is_a? Hash

      directions.map do |column, direction|
        model.arel_table[column].public_send(direction).nulls_last
      end
    end
  end

  extend Orders
end
